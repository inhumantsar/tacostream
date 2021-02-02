import 'package:hive/hive.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:tacostream/core/base/logger.dart';
import 'package:tacostream/core/base/model.dart';
import 'package:draw/draw.dart' as draw;

part 'redditor.g.dart';

final log = BaseLogger('RedditorModel');
final htmlUnescape = HtmlUnescape();

@HiveType(typeId: 2)
class Redditor extends BaseModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String displayName;
  @HiveField(3)
  final String credentials;

  Redditor({
    this.id,
    this.displayName,
    this.credentials,
  });

  // Equatable can implement toString method including all the given props
  // stringify => false disables this behaviour
  @override
  bool get stringify => false;

  @override
  String toString() {
    return "Redditor $displayName ($id)";
  }

  Map<String, Object> toMap() => {
        'id': this.id,
        'name': this.displayName,
        'credentials': this.credentials,
      };

  static Redditor fromMap(Map map) => new Redditor(
        id: map.containsKey('id') ? map['id'] : null,
        displayName: map.containsKey('displayName') ? map['displayName'] : null,
        credentials: map.containsKey('credentials') ? map['credentials'] : null,
      );

  static Redditor fromDraw(draw.Redditor c, String credentials) {
    // richtext flairs helpfully provide the image url, but we need to do some work to get it

    return Redditor(id: c.id, displayName: c.displayName, credentials: credentials);
  }

  @override
  get props => this.toMap().values.toList();
}
