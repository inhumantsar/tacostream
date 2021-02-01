import 'package:html_unescape/html_unescape.dart';
import 'package:tacostream/core/base/logger.dart';
import 'package:tacostream/core/base/model.dart';
import 'package:tacostream/models/comment.dart';
import 'package:draw/draw.dart' as draw;

final log = BaseLogger('ThreadModel');
final htmlUnescape = HtmlUnescape();

class Thread extends BaseModel {
  final Comment parent;
  final List<Thread> replies;

  Thread({this.parent, this.replies});

  // Equatable can implement toString method including all the given props
  // stringify => false disables this behaviour
  @override
  bool get stringify => false;

  @override
  String toString() {
    return "Thread with parent ${parent.runtimeType} ${parent.id} by ${parent.author} at ${parent.createdUtc}";
  }

  Map<String, Object> toMap() => {
        'parent': parent.toMap(),
        'replies': replies.map((e) => e.toMap()).toList(),
      };

  static Thread fromMap(Map map) => new Thread(
        parent: Comment.fromMap(map['parent']),
        replies: map['replies'].map((e) => e.toMap()).toList(),
      );

  static Future<Thread> fromDrawThread(draw.Comment c) async {
    // if (c.d) c = await c.populate();
    log.debug('creating thread from ${c.runtimeType} ${c.id}');
    return Thread(
        parent: Comment.fromDrawComment(c),
        replies: await Stream.fromIterable(c.replies?.comments ?? [])
            .asyncMap((c) async => await Thread.fromDrawThread(c))
            .toList());
  }

  @override
  get props => this.toMap().values.toList();
}
