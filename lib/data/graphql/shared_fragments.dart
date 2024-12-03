String metaDataToString(List<Map<String, dynamic>> metaData) {
  final metaDataString = metaData.map((item) {
    return '{ key: "${item['key']}", value: "${item['value']}" }';
  }).join(', ');
  return '[$metaDataString]';
}

String lineToString(List<Map<String, dynamic>> line) {
  final lineString = line.map((item) {
    final subProductsString = item['subProducts'].map((subProduct) => '''
      {
        addonProductId: "${subProduct['addonProductId']}",
        name: "${subProduct['name']}",
        price: ${subProduct['price']},
        qty: ${subProduct['qty']}
      }
    ''').join(', ');

    return '''
      {
        mProductId: "${item['mProductId']}",
        qty: ${item['qty']},
        unitprice: ${item['unitprice']},
        linenet: ${item['linenet']},
        linetax: ${item['linetax']},
        linegross: ${item['linegross']},
        subProducts: [$subProductsString]
      }
    ''';
  }).join(', ');
  return '[$lineString]';
}
