import 'package:tacostream/core/base/model.dart';

class Comment extends BaseModel {
  final String id;
  final String name;
  final String permalink;
  final int createdUtc;
  final bool deleted;
  final int ups;
  final int downs;
  final bool likes;
  final String author;
  final String authorFlairCssClass;
  final String authorFlairText;
  final String linkAuthor;
  final String linkUrl;
  final String linkTitle;
  final String subreddit;
  final String subredditId;
  final String body;
  final String bodyHtml;
  final String parentId;
  final String replies;
  final String more;
  final int gilded;
  final String distinguished;

  Comment(
      {this.id,
      this.name,
      this.permalink,
      this.createdUtc,
      this.deleted,
      this.ups,
      this.downs,
      this.likes,
      this.author,
      this.authorFlairCssClass,
      this.authorFlairText,
      this.linkAuthor,
      this.linkUrl,
      this.linkTitle,
      this.subreddit,
      this.subredditId,
      this.body,
      this.bodyHtml,
      this.parentId,
      this.replies,
      this.more,
      this.gilded,
      this.distinguished});

  // Equatable can implement toString method including all the given props
  // stringify => false disables this behaviour
  @override
  bool get stringify => false;

  @override
  String toString() {
    return "Comment by $author at $createdUtc";
  }

  @override
  Map<String, Object> toMap() {
    return {
      'ID': this.id,
      'Name': this.name,
      'Permalink': this.permalink,
      'CreatedUTC': this.createdUtc,
      'Deleted': this.deleted,
      'Ups': this.ups,
      'Downs': this.downs,
      'Likes': this.likes,
      'Author': this.author,
      'AuthorFlairCSSClass': this.authorFlairCssClass,
      'AuthorFlairText': this.authorFlairText,
      'LinkAuthor': this.linkAuthor,
      'LinkURL': this.linkUrl,
      'LinkTitle': this.linkTitle,
      'Subreddit': this.subreddit,
      'SubredditID': this.subredditId,
      'Body': this.body,
      'BodyHTML': this.bodyHtml,
      'ParentID': this.parentId,
      'Replies': this.replies,
      'More': this.more,
      'Gilded': this.gilded,
      'Distinguished': this.distinguished,
    };
  }

  static Comment fromMap(Map map) {
    return Comment(
      id: map.containsKey('ID') ? map['ID'] : null,
      name: map.containsKey('Name') ? map['Name'] : null,
      permalink: map.containsKey('Permalink') ? map['Permalink'] : null,
      createdUtc: map.containsKey('CreatedUTC') ? map['CreatedUTC'] : null,
      deleted: map.containsKey('Deleted') ? map['Deleted'] : null,
      ups: map.containsKey('Ups') ? map['Ups'] : null,
      downs: map.containsKey('Downs') ? map['Downs'] : null,
      likes: map.containsKey('Likes') ? map['Likes'] : null,
      author: map.containsKey('Author') ? map['Author'] : null,
      authorFlairCssClass: map.containsKey('AuthorFlairCSSClass')
          ? map['AuthorFlairCSSClass']
          : null,
      authorFlairText:
          map.containsKey('AuthorFlairText') ? map['AuthorFlairText'] : null,
      linkAuthor: map.containsKey('LinkAuthor') ? map['LinkAuthor'] : null,
      linkUrl: map.containsKey('LinkURL') ? map['LinkURL'] : null,
      linkTitle: map.containsKey('LinkTitle') ? map['LinkTitle'] : null,
      subreddit: map.containsKey('Subreddit') ? map['Subreddit'] : null,
      subredditId: map.containsKey('SubredditID') ? map['SubredditID'] : null,
      body: map.containsKey('Body') ? map['Body'] : null,
      bodyHtml: map.containsKey('BodyHTML') ? map['BodyHTML'] : null,
      parentId: map.containsKey('ParentID') ? map['ParentID'] : null,
      replies: map.containsKey('Replies') ? map['Replies'] : null,
      more: map.containsKey('More') ? map['More'] : null,
      gilded: map.containsKey('Gilded') ? map['Gilded'] : null,
      distinguished:
          map.containsKey('Distinguished') ? map['Distinguished'] : null,
    );
  }

  @override
  get props => this.toMap().values.toList();
}
