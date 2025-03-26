import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class SearchBarWidget extends StatefulWidget {
  final VoidCallback onSearchTap;
  final ValueChanged<String> onSearchQueryChanged;

  const SearchBarWidget({
    super.key,
    required this.onSearchTap,
    required this.onSearchQueryChanged,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _initSpeechRecognizer();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Initialize the speech recognition
  Future<void> _initSpeechRecognizer() async {
    bool available = await _speechToText.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() {
            _isListening = false;
          });
        }
      },
      onError: (error) {
        print("Speech recognition error: $error");
        setState(() {
          _isListening = false;
        });
      },
    );
    if (!available) {
      print("Speech recognition not available on this device");
    }
  }

  // Request microphone permission
  Future<bool> _requestMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (status.isDenied) {
      status = await Permission.microphone.request();
    }
    return status.isGranted;
  }

  // Start listening for speech
  Future<void> _startListening() async {
    bool hasPermission = await _requestMicrophonePermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required for voice search')),
      );
      return;
    }

    if (!_isListening) {
      bool available = await _speechToText.initialize();
      if (available) {
        setState(() {
          _isListening = true;
        });
        await _speechToText.listen(
          onResult: (result) {
            if (result.finalResult) {
              setState(() {
                _searchController.text = result.recognizedWords;
                _isListening = false;
                // Notify parent about the new search query
                widget.onSearchQueryChanged(result.recognizedWords);
              });
            }
          },
        );
      }
    } else {
      setState(() {
        _isListening = false;
        _speechToText.stop();
      });
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      widget.onSearchQueryChanged('');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: widget.onSearchTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white,
              width: 1,
            ),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: const TextStyle(
                color: Color.fromRGBO(189, 189, 189, 1),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: const Icon(Icons.search,
                  color: Color.fromRGBO(189, 189, 189, 1)),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Only show clear button when there's text
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: _clearSearch,
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(255, 233, 233, 1),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Color.fromRGBO(254, 33, 33, 1),
                          size: 16,
                        ),
                      ),
                    ),
                  // Voice search button with dynamic icon based on listening state
                  GestureDetector(
                    onTap: _startListening,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: _isListening ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              border: InputBorder.none,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: widget.onSearchQueryChanged,
          ),
        ),
      ),
    );
  }
}