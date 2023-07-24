import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

Future<double?> tillGetSource(Stream<double> source) async {
  await for (double value in source) {
    if (value > 0) {
      return value;
    }
  }
  return null; // No positive value found
}

class _SignupPageState extends State<SignupPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double?>(
      future: tillGetSource(Stream<double>.periodic(Duration(milliseconds: 100), (_) => MediaQuery.of(context).size.width)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Future가 완료되지 않았을 때 표시할 UI
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          // Future가 성공적으로 완료되었을 때 표시할 UI
          double value = snapshot.data!;
          Size screenSize = MediaQuery.of(context).size;
          return Scaffold(
            body: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                SizedBox(height: screenSize.height * 0.13),
                Padding(
                padding: EdgeInsets.only(left: screenSize.width * 0.043),
                child: Text(
              '안녕하세요!\nGIST 이메일로 간편가입해주세요!',
              style: TextStyle(
                color: Color(0xFF552619),
                fontFamily: 'Pretendard-SemiBold',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
            SizedBox(height: screenSize.height * 0.01),
            Padding(
                padding: EdgeInsets.only(left: screenSize.width * 0.043),
                child: Text(
              'GIST 이메일은 본인 확인 용도로 사용되며 다른 학우들에게\n공개되지 않습니다. ',
              style: TextStyle(
                color: Color(0xFF552619),
                fontFamily: 'Pretendard-Regular',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                height: 1.35,
              ),
            ),
          ),
            SizedBox(height: screenSize.height * 0.02),
            Row (
              children: [
                Container(
              padding: EdgeInsets.only(left: screenSize.width * 0.043),
              width: screenSize.width * 0.51, 
              height: 36,
             child: TextField(
               decoration: InputDecoration(
               border: UnderlineInputBorder(),
               labelText: 'GIST 이메일 입력',
               labelStyle: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.w400, 
                fontFamily: 'Pretendard-Regular', 
                color: Color(0xFFCCBEBA) 
            ),
                 ),
              ),
             ),
             SizedBox(width: screenSize.width * 0.02),
              ElevatedButton(
                    onPressed: () {
                      // 버튼이 눌렸을 때의 동작
                      print("시작하기 버튼이 눌렸습니다.");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Color(0xFF552619), width: 1.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Container(
                      width: screenSize.width * 0.19,
                      height: screenSize.height * 0.024,
                      alignment: Alignment.center,
                      child: Text(
                        '인증메일 발송',
                        style: TextStyle(
                          color: Color(0xFF552619),
                          fontFamily: 'Pretendard-Medium',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),      
                 ],
                ),
                SizedBox(height: screenSize.height * 0.48),
                Padding(
                padding: EdgeInsets.only(left: screenSize.width * 0.043),
              child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                       context,
                       MaterialPageRoute(builder: (context) => SignupPage()), // LoginPage로 이동합니다.
            );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Color(0xFFC30020), width: 1.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Container(
                      width: screenSize.width * 0.81,
                      height: screenSize.height * 0.056,
                      alignment: Alignment.center,
                      child: Text(
                        '인증',
                        style: TextStyle(
                          color: Color(0xFFC30020),
                          fontFamily: 'Pretendard-Medium',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
               ],
               
              ),
            );
        }
        return Container();
      },
    );
  }
}