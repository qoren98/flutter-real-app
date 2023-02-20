import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_app/common/component/custom_text_form_field.dart';
import 'package:flutter_real_app/common/const/colors.dart';
import 'package:flutter_real_app/common/const/data.dart';
import 'package:flutter_real_app/common/layout/default_layout.dart';
import 'package:flutter_real_app/common/view/root_tab.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String userName = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    final dio = Dio();

    return DefaultLayout(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: SafeArea(
          top: true,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Title(),
                const SizedBox(
                  height: 16.0,
                ),
                const _SubTitle(),
                const SizedBox(
                  height: 24.0,
                ),
                Image.asset(
                  'asset/img/misc/logo.png',
                  height: MediaQuery.of(context).size.height / 3,
                ),
                const SizedBox(
                  height: 24.0,
                ),
                CustomTextFormField(
                  hintText: "이메일을 입력해 주세요",
                  onChanged: (String value) {
                    userName = value;
                  },
                ),
                const SizedBox(
                  height: 16.0,
                ),
                CustomTextFormField(
                  hintText: "비밀번호를 입력해 주세요",
                  obscureText: true,
                  onChanged: (String value) {
                    password = value;
                  },
                ),
                const SizedBox(
                  height: 16.0,
                ),
                ElevatedButton(
                  onPressed: () async {
                    // ID:비밀번호를 Base64방식으로 인코딩하기
                    final rawString = '$userName:$password';
                    Codec<String, String> stringToBase64 = utf8.fuse(base64);
                    String token = stringToBase64.encode(rawString);

                    final response = await dio.post(
                      'http://$ip/auth/login',
                      options: Options(
                        headers: {
                          'authorization': 'Basic $token',
                        },
                      ),
                    );

                    final refreshToken = response.data['refreshToken'];
                    final accessToken = response.data['accessToken'];

                    await storage.write(
                        key: REFRESH_TOKEN_KEY, value: refreshToken);
                    await storage.write(
                        key: ACCESS_TOKEN_KEY, value: accessToken);

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const RootTab(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PRIMARY_COLOR,
                  ),
                  child: const Text('로그인'),
                ),
                TextButton(
                  onPressed: () async {},
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('회원가입'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return const Text(
      '환영합니다.',
      style: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _SubTitle extends StatelessWidget {
  const _SubTitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      '이메일과 비밀번호를 입력해서 로그인해 주세요! \n오늘도 성공적인 주문이 되길... :)',
      style: TextStyle(
        fontSize: 16,
        color: BODY_TEXT_COLOR,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
