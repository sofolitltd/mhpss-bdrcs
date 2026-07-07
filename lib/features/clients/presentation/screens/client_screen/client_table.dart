import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/core/design_system/app_design_system.dart';
import '../../../domain/models/client.dart';

class ClientTable extends StatelessWidget {
  final List<Client> clients;
  final void Function(Client client) onDelete;

  const ClientTable({required this.clients, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final border = isDark ? AppColors.borderDark : AppColors.border;

    return DataTable(
      headingRowColor: WidgetStateProperty.all(
        AppColors.primary.withValues(alpha: 0.08),
      ),
      border: TableBorder.all(color: border, borderRadius: AppRadius.roundedSm),
      columnSpacing: 16,
      columns: const [
        DataColumn(
          label: Text('Case ID', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataColumn(
          label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataColumn(
          label: Text('Address', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataColumn(
          label: Text(
            'District',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text('Gender', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataColumn(
          label: Text('Age', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataColumn(
          label: Text(
            'Category',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text('Note', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataColumn(
          label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataColumn(
          label: Text(
            'Alt Phone',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Join Date',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
      rows: clients.map((c) {
        return DataRow(
          cells: [
            DataCell(Text(c.caseId, style: TextStyle(color: textPrimary))),
            DataCell(HoverableNameCell(client: c)),
            DataCell(Text(c.address, style: TextStyle(color: textPrimary))),
            DataCell(Text(c.district, style: TextStyle(color: textPrimary))),
            DataCell(Text(c.gender, style: TextStyle(color: textPrimary))),
            DataCell(Text(c.ageRange, style: TextStyle(color: textPrimary))),
            DataCell(
              c.category.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        c.category,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : const Text(''),
            ),
            DataCell(
              Text(
                c.note,
                style: TextStyle(
                  color: textPrimary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            DataCell(Text(c.phone ?? '', style: TextStyle(color: textPrimary))),
            DataCell(
              Text(
                c.alternatePhone ?? '',
                style: TextStyle(color: textPrimary),
              ),
            ),
            DataCell(
              Text(
                c.joinDate != null
                    ? '${c.joinDate!.day.toString().padLeft(2, '0')}/${c.joinDate!.month.toString().padLeft(2, '0')}/${c.joinDate!.year}'
                    : '',
                style: TextStyle(color: textPrimary),
              ),
            ),
            DataCell(
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  size: 18,
                  color: textPrimary,
                ),
                padding: EdgeInsets.zero,
                onSelected: (value) {
                  switch (value) {
                    case 'view':
                      context.go('/clients/${c.id}/about');
                      break;
                    case 'edit':
                      context.go('/clients/${c.id}/about');
                      break;
                    case 'delete':
                      onDelete(c);
                      break;
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: ListTile(
                      dense: true,
                      leading: Icon(Icons.visibility_outlined, size: 20),
                      title: Text('View Details'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      dense: true,
                      leading: Icon(Icons.edit_outlined, size: 20),
                      title: Text('Edit'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.red,
                      ),
                      title: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class HoverableNameCell extends StatefulWidget {
  final Client client;
  const HoverableNameCell({required this.client});

  @override
  State<HoverableNameCell> createState() => HoverableNameCellState();
}

class HoverableNameCellState extends State<HoverableNameCell> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => context.go('/clients/${widget.client.id}/about'),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Text(
            widget.client.capitalizedName,
            style: TextStyle(
              color: _isHovered ? AppColors.primary : textPrimary,
              decoration: _isHovered ? TextDecoration.underline : null,
            ),
          ),
        ),
      ),
    );
  }
}
