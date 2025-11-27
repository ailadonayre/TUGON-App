import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/colors.dart';
import '../../utils/responsive.dart';

/// Example screen demonstrating responsive design patterns
/// This screen showcases all the responsive features available in the app
class ResponsiveDemoScreen extends StatelessWidget {
  const ResponsiveDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Responsive Demo',
          style: GoogleFonts.dmSans(
            fontSize: responsive.fontSize(20),
          ),
        ),
        toolbarHeight: responsive.spacing(56),
      ),
      body: ResponsiveContainer(
        child: ListView(
          padding: responsive.pagePadding,
          children: [
            _buildDeviceInfo(responsive),
            SizedBox(height: responsive.spacing(24)),
            _buildSizingDemo(responsive),
            SizedBox(height: responsive.spacing(24)),
            _buildGridDemo(responsive),
            SizedBox(height: responsive.spacing(24)),
            _buildResponsiveLayoutDemo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfo(Responsive responsive) {
    return Card(
      child: Padding(
        padding: responsive.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Device Information',
              style: GoogleFonts.dmSans(
                fontSize: responsive.fontSize(18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: responsive.spacing(16)),
            _buildInfoRow(
              'Screen Width',
              '${responsive.screenWidth.toStringAsFixed(0)}px',
              responsive,
            ),
            _buildInfoRow(
              'Screen Height',
              '${responsive.screenHeight.toStringAsFixed(0)}px',
              responsive,
            ),
            _buildInfoRow(
              'Device Type',
              responsive.isMobile
                  ? 'Mobile'
                  : responsive.isTablet
                      ? 'Tablet'
                      : 'Desktop',
              responsive,
            ),
            _buildInfoRow(
              'Orientation',
              responsive.isPortrait ? 'Portrait' : 'Landscape',
              responsive,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Responsive responsive) {
    return Padding(
      padding: EdgeInsets.only(bottom: responsive.spacing(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: responsive.fontSize(14),
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: responsive.fontSize(14),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizingDemo(Responsive responsive) {
    return Card(
      child: Padding(
        padding: responsive.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Responsive Sizing',
              style: GoogleFonts.dmSans(
                fontSize: responsive.fontSize(18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: responsive.spacing(16)),
            Container(
              width: responsive.wp(100),
              height: responsive.spacing(40),
              color: AppColors.lightYellow,
              alignment: Alignment.center,
              child: Text(
                '100% Width',
                style: GoogleFonts.dmSans(fontSize: responsive.fontSize(14)),
              ),
            ),
            SizedBox(height: responsive.spacing(8)),
            Container(
              width: responsive.wp(50),
              height: responsive.spacing(40),
              color: AppColors.goldenYellow,
              alignment: Alignment.center,
              child: Text(
                '50% Width',
                style: GoogleFonts.dmSans(
                  fontSize: responsive.fontSize(14),
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: responsive.spacing(16)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  Icons.star,
                  size: responsive.iconSize(24),
                  color: AppColors.goldenYellow,
                ),
                Icon(
                  Icons.star,
                  size: responsive.iconSize(32),
                  color: AppColors.goldenYellow,
                ),
                Icon(
                  Icons.star,
                  size: responsive.iconSize(48),
                  color: AppColors.goldenYellow,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridDemo(Responsive responsive) {
    return Card(
      child: Padding(
        padding: responsive.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Responsive Grid (${responsive.gridColumns} columns)',
              style: GoogleFonts.dmSans(
                fontSize: responsive.fontSize(18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: responsive.spacing(16)),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: responsive.gridColumns,
                crossAxisSpacing: responsive.spacing(12),
                mainAxisSpacing: responsive.spacing(12),
                childAspectRatio: 1,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.lightYellow,
                    borderRadius: BorderRadius.circular(responsive.radius(12)),
                    border: Border.all(
                      color: AppColors.goldenYellow.withOpacity(0.3),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.dmSans(
                      fontSize: responsive.fontSize(24),
                      fontWeight: FontWeight.bold,
                      color: AppColors.goldenYellow,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveLayoutDemo(BuildContext context) {
    final responsive = Responsive(context);

    return Card(
      child: Padding(
        padding: responsive.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Responsive Layout Widget',
              style: GoogleFonts.dmSans(
                fontSize: responsive.fontSize(18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: responsive.spacing(16)),
            ResponsiveLayout(
              mobile: _buildLayoutCard('Mobile Layout', AppColors.brightBlue, responsive),
              tablet: _buildLayoutCard('Tablet Layout', AppColors.goldenYellow, responsive),
              desktop: _buildLayoutCard('Desktop Layout', AppColors.coralRed, responsive),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayoutCard(String text, Color color, Responsive responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.spacing(16)),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(responsive.radius(12)),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          fontSize: responsive.fontSize(16),
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
