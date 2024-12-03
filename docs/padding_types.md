1. All Sides Padding -
   padding: const EdgeInsets.all(16), // Padding on all four sides

2. Symmetric Padding
   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8); // Horizontal and vertical
   padding

3. Only Specific Sides Padding
   Top, Left, Right Padding
   padding: const EdgeInsets.only(top: 16, left: 16, right: 16); // Padding for top, left, and right

   Bottom Padding
   padding: const EdgeInsets.only(bottom: 16); // Padding only at the bottom

   Left Padding
   padding: const EdgeInsets.only(left: 16); // Padding only on the left

   Right Padding
   padding: const EdgeInsets.only(right: 16); // Padding only on the right

   Top Padding
   padding: const EdgeInsets.only(top: 16); // Padding only on the top

4. From Specific Values
   padding: const EdgeInsets.fromLTRB(left, top, right, bottom); // Custom padding for each side
   padding: const EdgeInsets.fromLTRB(16, 8, 16, 0); // Left: 16, Top: 8, Right: 16, Bottom: 0

5. Zero Padding
   padding: const EdgeInsets.zero; // No padding at all
