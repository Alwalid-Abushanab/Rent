class RenterInfo{
  final String name;
  final int apartmentNum;
  final double rent;
  final DateTime LastPaymentDate;
  final int paymentFrequency;

  RenterInfo({required this.name, required this.apartmentNum, required this.rent, required this.LastPaymentDate, required this.paymentFrequency});
}