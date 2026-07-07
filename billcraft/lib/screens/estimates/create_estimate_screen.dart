import 'package:flutter/material.dart';
import '../../screens/invoices/create_invoice_screen.dart';

// Reuses the CreateInvoiceScreen logic with isEstimate=true
class CreateEstimateScreen extends StatelessWidget {
  const CreateEstimateScreen({super.key});

  @override
  Widget build(BuildContext context) => const CreateInvoiceScreen();
}
