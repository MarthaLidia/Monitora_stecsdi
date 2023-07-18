/// @Author: *Luis García Castro **(luis.garcia@bisigma.com)***
/// @Created: 2022-01-20
/// @Updated:

part of ec.gob.infancia.ecuadorsincero.core;

class ModelUser {
  final String username;
  final bool enabled;
  final bool accountNonExpired;
  final bool accountNonLocked;
  final bool credentialsNonExpired;
  final List<String> authorities;
  final List<String> claims;
  final ModelUserInfo info;

  ModelUser({
    required this.username,
    required this.enabled,
    required this.accountNonExpired,
    required this.accountNonLocked,
    required this.credentialsNonExpired,
    required this.authorities,
    required this.claims,
    required this.info,
  });

  factory ModelUser.from(Map<String, dynamic> obj) => ModelUser(
        username: obj['username'],
        enabled: obj['enabled'],
        accountNonExpired: obj['accountNonExpired'],
        accountNonLocked: obj['accountNonLocked'],
        credentialsNonExpired: obj['credentialsNonExpired'],
        authorities: obj['authorities']
            .map((auth) => auth['authority'])
            .toList()
            .cast<String>(),
        claims: obj['claims'].cast<String>(),
        info: ModelUserInfo.from(obj['info']),
      );

  factory ModelUser.db(Map<String, dynamic> obj) => ModelUser(
        username: obj['u_username'],
        enabled: obj['u_enabled'] == 1 ? true : false,
        accountNonExpired: obj['u_accountNonExpired'] == 1 ? true : false,
        accountNonLocked: obj['u_accountNonLocked'] == 1 ? true : false,
        credentialsNonExpired:
            obj['u_credentialsNonExpired'] == 1 ? true : false,
        authorities: jsonDecode(obj['u_authorities']).cast<String>(),
        claims: jsonDecode(obj['u_claims']).cast<String>(),
        info: ModelUserInfo.db(obj),
      );

  Map<String, dynamic> toJsonDb() => {
        'u_username': username,
        'u_enabled': enabled ? 1 : 0,
        'u_accountNonExpired': accountNonExpired ? 1 : 0,
        'u_accountNonLocked': accountNonLocked ? 1 : 0,
        'u_credentialsNonExpired': credentialsNonExpired ? 1 : 0,
        'u_authorities': jsonEncode(authorities),
        'u_claims': jsonEncode(claims),
        'u_id': info.id,
        'u_status': info.status ? 1 : 0,
        'u_user': info.user,
        'u_date': info.date.toIso8601String(),
        'u_documentTypeId': info.documentTypeId,
        'u_documentTypeName': info.documentTypeName,
        'u_document': info.document,
        'u_fullName': info.fullName,
      };

  factory ModelUser.empty() => ModelUser(
        username: '',
        enabled: false,
        accountNonExpired: false,
        accountNonLocked: false,
        credentialsNonExpired: false,
        authorities: [],
        claims: [],
        info: ModelUserInfo.empty(),
      );

  @override
  toString() {
    return '''{ 'username': $username, 'claims': $claims, info: $info }''';
  }
}
