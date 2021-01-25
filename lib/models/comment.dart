import 'package:hive/hive.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:tacostream/core/base/logger.dart';
import 'package:tacostream/core/base/model.dart';
import 'package:draw/draw.dart' as draw;

part 'comment.g.dart';

final log = BaseLogger('CommentModel');
final htmlUnescape = HtmlUnescape();

@HiveType(typeId: 1)
class Comment extends BaseModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String permalink;
  @HiveField(3)
  final DateTime createdUtc;
  @HiveField(4)
  final bool removed;
  @HiveField(5)
  final int upvotes;
  @HiveField(6)
  final int downvotes;
  @HiveField(7)
  final String author;
  @HiveField(8)
  final String authorFlairImageUrl;
  @HiveField(9)
  final String authorFlairText;
  @HiveField(10)
  final String body;
  @HiveField(11)
  final String parentId;

  Comment(
      {this.id,
      this.name,
      this.permalink,
      this.createdUtc,
      this.removed,
      this.upvotes,
      this.downvotes,
      this.author,
      this.authorFlairImageUrl,
      this.authorFlairText,
      this.body,
      this.parentId});

  // Equatable can implement toString method including all the given props
  // stringify => false disables this behaviour
  @override
  bool get stringify => false;

  @override
  String toString() {
    return "Comment by $author at $createdUtc";
  }

  Map<String, Object> toMap() => {
        'id': this.id,
        'name': this.name,
        'permalink': this.permalink,
        'createdUtc': this.createdUtc,
        'removed': this.removed,
        'upvotes': this.upvotes,
        'downvotes': this.downvotes,
        'author': this.author,
        'authorFlairImageUrl': this.authorFlairImageUrl,
        'authorFlairText': this.authorFlairText,
        'body': this.body,
        'parentId': this.parentId
      };

  static Comment fromMap(Map map) => new Comment(
        id: map.containsKey('id') ? map['id'] : null,
        name: map.containsKey('name') ? map['name'] : null,
        permalink: map.containsKey('permalink') ? map['permalink'] : null,
        createdUtc: map.containsKey('createdUtc') ? map['createdUtc'] : null,
        removed: map.containsKey('removed') ? map['removed'] : null,
        upvotes: map.containsKey('upvotes') ? map['upvotes'] : null,
        downvotes: map.containsKey('downvotes') ? map['downvotes'] : null,
        author: map.containsKey('author') ? map['author'] : null,
        authorFlairImageUrl:
            map.containsKey('authorFlairImageUrl') ? map['authorFlairImageUrl'] : null,
        authorFlairText: map.containsKey('authorFlairText') ? map['authorFlairText'] : null,
        body: map.containsKey('body') ? map['body'] : null,
        parentId: map.containsKey('parentId') ? map['parentId'] : null,
      );

  static Comment fromDrawComment(draw.Comment c) {
    // richtext flairs helpfully provide the image url, but we need to do some work to get it
    var authorFlairImageUrl = "";
    var authorFlairText = c.authorFlairText;
    if (c.data.containsKey('author_flair_richtext')) {
      List flair = c.data['author_flair_richtext'];
      flair.forEach((f) {
        if (f['e'] == "text") authorFlairText = f['t'];
        if (f['e'] == "emoji") authorFlairImageUrl = f['u'];
      });
      log.debug('flair: $authorFlairText $authorFlairImageUrl');
    }

    var body = htmlUnescape.convert(c.body);

    return Comment(
        id: c.id,
        permalink: c.permalink,
        createdUtc: c.createdUtc,
        removed: c.removed,
        upvotes: c.upvotes,
        downvotes: c.downvotes,
        author: c.author,
        authorFlairImageUrl: authorFlairImageUrl,
        authorFlairText: authorFlairText,
        body: body,
        parentId: c.parentId);
  }

  @override
  get props => this.toMap().values.toList();
}
