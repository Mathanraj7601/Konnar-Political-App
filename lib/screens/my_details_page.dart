// import 'package:flutter/material.dart';
// import '../services/navigation_service.dart';

// class MyDetailsPage extends StatelessWidget {
//   const MyDetailsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F6FB),

//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: Builder(
//           builder: (context) {
//             final screenWidth = MediaQuery.of(context).size.width;
//             final isSmallScreen = screenWidth < 360;
//             final isTablet = screenWidth >= 768;
            
//             return IconButton(
//               icon: Icon(
//                 Icons.arrow_back_ios_new,
//                 color: Colors.black87,
//                 size: isTablet ? 26 : (isSmallScreen ? 20 : 24),
//               ),
//               onPressed: () {
//                 // Use Navigator.pop to go back to previous page (Profile)
//                 Navigator.pop(context);
//               },
//               padding: EdgeInsets.all(isTablet ? 16 : 12),
//               constraints: BoxConstraints(
//                 minWidth: isTablet ? 56 : 48,
//                 minHeight: isTablet ? 56 : 48,
//               ),
//             );
//           },
//         ),
//         title: const Text(
//           "My Details",
//           style: TextStyle(
//             color: Colors.black87,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//         titleSpacing: 0,
//       ),

//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // 🔥 PROFILE CARD
//             Container(
//               padding: const EdgeInsets.all(14),
//               decoration: _card(),
//               child: Row(
//                 children: [
//                   const CircleAvatar(
//                     radius: 32,
//                     backgroundImage: NetworkImage(
//                       "https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg",
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: const [
//                       Text("Arjun Kumar",
//                           style: TextStyle(
//                               fontWeight: FontWeight.w600, fontSize: 16)),
//                       SizedBox(height: 4),
//                       Text("+91 9876543210",
//                           style: TextStyle(color: Colors.grey)),
//                     ],
//                   )
//                 ],
//               ),
//             ),

//             const SizedBox(height: 16),

//             // 🔲 DETAILS CARD
//             _cardSection([
//               _row(Icons.person, "Full Name", "Arjun Kumar"),
//               _divider(),
//               _row(Icons.phone, "Mobile Number", "9876543210"),
//               _divider(),
//               _row(Icons.calendar_today, "Date of Birth", "15 Mar 2001"),
//               _divider(),
//               _row(Icons.people, "Gender", "Male"),
//               _divider(),
//               _row(Icons.person_outline, "Father / Guardian Name", "R. Sekar"),
//             ]),

//             const SizedBox(height: 16),

//             // 📍 ADDRESS CARD
//             _cardSection([
//               _sectionTitle(Icons.location_on, "Address"),
//               _divider(),
//               _row(Icons.location_on, "Street", "New Street, Chennai"),
//               _divider(),
//               _row(Icons.home, "Door No", "123"),
//               _divider(),
//               _row(Icons.location_city, "City / Village", "Kanchipuram"),
//               _divider(),
//               _row(Icons.map, "District", "Menai"),
//               _divider(),
//               _row(Icons.place, "Constituency", "Kanchipuram"),
//             ]),

//             const SizedBox(height: 24),

//             // 🔘 BUTTON
//             Container(
//               height: 55,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFF1E2A78), Color(0xFF2F3FA0)],
//                 ),
//                 borderRadius: BorderRadius.circular(30),
//               ),
//               alignment: Alignment.center,
//               child: const Text(
//                 "Edit Profile",
//                 style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 16),
//               ),
//             ),

//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   // 🔲 CARD WRAPPER
//   Widget _cardSection(List<Widget> children) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       decoration: _card(),
//       child: Column(children: children),
//     );
//   }

//   // 🔹 ROW ITEM
//   Widget _row(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: const Color(0xFFF3F5FA),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(icon, color: const Color(0xFF1E2A78), size: 20),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(label,
//                     style:
//                         const TextStyle(fontSize: 12, color: Colors.grey)),
//                 const SizedBox(height: 2),
//                 Text(value,
//                     style: const TextStyle(
//                         fontSize: 14, fontWeight: FontWeight.w600)),
//               ],
//             ),
//           ),
//           const Icon(Icons.chevron_right, color: Colors.grey),
//         ],
//       ),
//     );
//   }

//   Widget _divider() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       child: Divider(color: Colors.grey.shade200),
//     );
//   }

//   Widget _sectionTitle(IconData icon, String title) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.orange),
//           const SizedBox(width: 8),
//           Text(title,
//               style:
//                   const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
//         ],
//       ),
//     );
//   }

//   BoxDecoration _card() {
//     return BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(20),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.05),
//           blurRadius: 10,
//         ),
//       ],
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'edit_profile_page.dart'; // ✅ IMPORT ADDED

class MyDetailsPage extends StatelessWidget {
  const MyDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isSmallScreen = screenWidth < 360;
            final isTablet = screenWidth >= 768;

            return IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black87,
                size: isTablet ? 26 : (isSmallScreen ? 20 : 24),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              padding: EdgeInsets.all(isTablet ? 16 : 12),
              constraints: BoxConstraints(
                minWidth: isTablet ? 56 : 48,
                minHeight: isTablet ? 56 : 48,
              ),
            );
          },
        ),
        title: const Text(
          "My Details",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        titleSpacing: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // 🔥 PROFILE CARD
            Container(
              padding: const EdgeInsets.all(14),
              decoration: _card(),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundImage: NetworkImage(
                      "https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Arjun Kumar",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      SizedBox(height: 4),
                      Text("+91 9876543210",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🔲 DETAILS CARD
            _cardSection([
              _row(Icons.person, "Full Name", "Arjun Kumar"),
              _divider(),
              _row(Icons.phone, "Mobile Number", "9876543210"),
              _divider(),
              _row(Icons.calendar_today, "Date of Birth", "15 Mar 2001"),
              _divider(),
              _row(Icons.people, "Gender", "Male"),
              _divider(),
              _row(Icons.person_outline, "Father / Guardian Name", "R. Sekar"),
            ]),

            const SizedBox(height: 16),

            // 📍 ADDRESS CARD
            _cardSection([
              _sectionTitle(Icons.location_on, "Address"),
              _divider(),
              _row(Icons.location_on, "Street", "New Street, Chennai"),
              _divider(),
              _row(Icons.home, "Door No", "123"),
              _divider(),
              _row(Icons.location_city, "City / Village", "Kanchipuram"),
              _divider(),
              _row(Icons.map, "District", "Menai"),
              _divider(),
              _row(Icons.place, "Constituency", "Kanchipuram"),
            ]),

            const SizedBox(height: 24),

            // 🔘 EDIT PROFILE BUTTON (✅ UPDATED)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfilePage(),
                  ),
                );
              },
              child: Container(
                height: 55,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E2A78), Color(0xFF2F3FA0)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Edit Profile",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 🔲 CARD WRAPPER
  Widget _cardSection(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: _card(),
      child: Column(children: children),
    );
  }

  // 🔹 ROW ITEM
  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F5FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF1E2A78), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Divider(color: Colors.grey.shade200),
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange),
          const SizedBox(width: 8),
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  BoxDecoration _card() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
        ),
      ],
    );
  }
}