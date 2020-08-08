import 'package:fast_orm/fast_orm.dart';

import 'article.dao.dart';

@DBTable("article")
class ArticleEntity {
  @DBProperty("id", isPrimary: true)
  String id;

  @DBProperty("article_title")
  String title;

  Future<List<ArticleEntity>> list() async {
    return await ArticleEntityDao.queryAll();
  }
}
