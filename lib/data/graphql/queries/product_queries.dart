// String getFetchProductQuery(String id) {
//   return """
//   query {
//     getProducts(commerceConfigId: "$id") {
//       product_id
//       category_id
//       categoryName
//       group_id
//       location_id
//       sku
//       name
//       menuName
//       available_start_time
//       available_end_time
//       taxCategories {
//         name
//         taxRate
//         csTaxcategoryID
//         parentTaxId
//       }
//       productioncenter
//       preparationtime
//       preorder
//       short_desc
//       veg
//       unitprice
//       listprice
//       imageUrl
//       bestseller
//       available
//       available_from
//       available_to
//       next_available_from
//       next_available_to
//       add_on_group {
//         id
//         type
//         name
//         minqty
//         maxqty
//         addOnItems {
//           id
//           name
//           price
//         }
//       }
//       attributeGroup {
//         id
//         name
//         attribute {
//           id
//           value
//           name
//         }
//       }
//       ingredients
//     }
//   }
//   """;
// }
