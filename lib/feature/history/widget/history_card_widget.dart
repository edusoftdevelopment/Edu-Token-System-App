
part of 'widget.dart';
class HistoryCard extends StatelessWidget {
  const HistoryCard({required this.item, super.key});
  final EduTokenSystemHistoryModel item;

  @override

  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Token No + Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Token #${item.tokenNo ?? '-'}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.grey,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.tokenDate ?? '',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Product Name
            Text(
              item.productName ?? 'Unknown Product',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            // Quantity & Rate
            Row(
              children: [
                _infoChip(
                  Icons.shopping_bag,
                  'Qty',
                  '${item.quantity ?? 0}',
                  Colors.blue,
                ),
                const SizedBox(width: 12),
                _infoChip(
                  Icons.monetization_on,
                  'Rate',
                  '${item.rate ?? 0}',
                  Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Vehicle
            Row(
              children: [
                const Icon(
                  Icons.directions_car,
                  color: Colors.deepOrange,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  item.vehicleNo ?? 'N/A',
                  style: const TextStyle(color: Colors.black87, fontSize: 15),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, String value, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: const TextStyle(color: Colors.black87, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
