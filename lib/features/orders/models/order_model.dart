class OrderModel {
  final String number;
  final String buyer;
  final String phone;
  final String product;
  final int quantity;
  final int totalPrice;
  final String status;
  final DateTime orderDate;
  final String paymentMethod;
  final String address;
  final String note;

  const OrderModel({
    required this.number,
    required this.buyer,
    required this.phone,
    required this.product,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    required this.orderDate,
    required this.paymentMethod,
    required this.address,
    this.note = '',
  });
}
