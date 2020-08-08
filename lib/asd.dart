import 'dao.dart';

@DBTable("asd")
class ASD extends DBEntity {
  @DBProperty("id", isPrimary: true)
  String id;

  /// 启用
  @DBProperty("enable", type: DBPropertyType.Bool)
  bool enable;
}
