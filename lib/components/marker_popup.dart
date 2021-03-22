import 'package:flutter/material.dart';
import 'package:whereabouts_client/services/mock_location.dart';

class MarkerPopup extends StatefulWidget {
  MarkerPopup(this.person);

  final Person person;

  @override
  _MarkerPopupState createState() => _MarkerPopupState();
}

class _MarkerPopupState extends State<MarkerPopup> {
  //1 minute, 2 minutes
  String getS(int time) {
    if (time == 1) {
      return "";
    } else {
      return "s";
    }
  }

  // Return a String with format "[passed time] [hour/minute/second] [s] ago"
  String timeSinceGet() {
    Duration timeSince = DateTime.now().difference(widget.person.time);
    if (timeSince.inHours > 0) {
      return timeSince.inHours.toString() + " hour" + getS(timeSince.inHours) + " ago";
    }
    if (timeSince.inMinutes > 0) {
      return timeSince.inMinutes.toString() + " minute" + getS(timeSince.inMinutes) + " ago";
    } else {
      return timeSince.inSeconds.toString() + " second" + getS(timeSince.inSeconds) + " ago";
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //Popup body
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey[300],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    widget.person.name,
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    timeSinceGet(),
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),

          //Popup pointer
          Container(
            height: 20,
            width: 42,
            decoration: ShapeDecoration(
              shape: InvertedCircleBorder(
                radius: 20,
                direction: InnerBorderDirection.bottom,
              ),
              color: Colors.grey[300],
            ),
          )
        ],
      ),
    );
  }
}

//This is a custom ShapeBorder that instead of making a rounding on the outside which folows the tangent of the edges
//juts inwards making a picture frame esque type border
class InvertedCircleBorder extends ShapeBorder {
  final double radius;
  final InnerBorderDirection direction;

  InvertedCircleBorder({@required this.radius, @required this.direction});

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    return Path.combine(PathOperation.difference, Path()..addRect(rect), _getRoundings(rect, radius));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection textDirection}) {}

  @override
  ShapeBorder scale(double t) => InvertedCircleBorder(radius: radius, direction: direction);

  Path _getRoundings(Rect rect, double radius) {
    Path path = Path();
    if (direction == InnerBorderDirection.all || direction == InnerBorderDirection.top || direction == InnerBorderDirection.left)
      path.addOval(Rect.fromCircle(center: Offset(rect.left, rect.top), radius: radius));
    if (direction == InnerBorderDirection.all || direction == InnerBorderDirection.top || direction == InnerBorderDirection.right)
      path.addOval(Rect.fromCircle(center: Offset(rect.left + rect.width, rect.top), radius: radius));
    if (direction == InnerBorderDirection.all || direction == InnerBorderDirection.bottom || direction == InnerBorderDirection.left)
      path.addOval(Rect.fromCircle(center: Offset(rect.left, rect.top + rect.height), radius: radius));
    if (direction == InnerBorderDirection.all || direction == InnerBorderDirection.bottom || direction == InnerBorderDirection.right)
      path.addOval(Rect.fromCircle(center: Offset(rect.left + rect.width, rect.top + rect.height), radius: radius));

    return path;
  }
}

//What corners should the border be applyed to?
enum InnerBorderDirection {
  all,
  left,
  top,
  right,
  bottom,
}
