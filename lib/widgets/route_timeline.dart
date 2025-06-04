import 'package:flutter/material.dart';
import '../models/kereta_model.dart';

enum StationStatus {
  start,
  passed,
  current,
  upcoming,
  destination,
}

class RouteTimeline extends StatelessWidget {
  final List<StasiunRoute> route;

  const RouteTimeline({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE91E63), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 16),
          _buildTimeline(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Route Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        Text(
          'Swipe →',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[500],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        height: 100,
        child: Stack(
          children: [
            _buildTimelineLine(),
            _buildActiveTimelineLine(),
            _buildStations(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineLine() {
    // Only draw lines between stations, not beyond the last one
    return Positioned(
      top: 10,
      left: 50,
      child: Row(
        children: [
          for (int i = 0; i < route.length - 1; i++) ...[
            Container(
              width: 100,
              height: 2,
              color: Colors.grey[300],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveTimelineLine() {
    // Calculate how much of the timeline should be active based on passed stations
    int passedCount = route.where((station) => station.isPassed).length;
    
    return Positioned(
      top: 10,
      left: 50,
      child: Row(
        children: [
          for (int i = 0; i < route.length - 1; i++) ...[
            Container(
              width: 100,
              height: 2,
              color: i < passedCount ? Color(0xFFE91E63) : Colors.grey[300],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStations() {
    return Row(
      children: [
        for (int i = 0; i < route.length; i++) ...[
          SizedBox(
            width: 100,
            child: _buildStationItem(
              route[i].nama,
              i == 0 ? 'Start' : (i == route.length - 1 ? 'Destination' : route[i].waktu),
              route[i].waktu,
              _getStationStatus(i, route[i]),
            ),
          ),
        ],
      ],
    );
  }

  StationStatus _getStationStatus(int index, StasiunRoute station) {
    if (index == 0) {
      return StationStatus.start;
    } else if (index == route.length - 1) {
      return StationStatus.destination;
    } else if (station.isPassed) {
      return StationStatus.passed;
    } else if (station.isActive) {
      return StationStatus.current;
    } else {
      return StationStatus.upcoming;
    }
  }

  Widget _buildStationItem(String name, String subtitle, String time, StationStatus status) {
    Widget icon;
    Color textColor;
    
    switch (status) {
      case StationStatus.start:
        icon = Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Color(0xFFE91E63),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Icon(
            Icons.train,
            size: 12,
            color: Colors.white,
          ),
        );
        textColor = Colors.black;
        break;
      case StationStatus.passed:
        icon = Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Color(0xFFE91E63),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            size: 12,
            color: Colors.white,
          ),
        );
        textColor = Colors.black;
        break;
      case StationStatus.current:
        icon = Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Color(0xFFE91E63),
            shape: BoxShape.circle,
          ),
        );
        textColor = Color(0xFFE91E63);
        break;
      case StationStatus.upcoming:
        icon = Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
          ),
        );
        textColor = Colors.black;
        break;
      case StationStatus.destination:
        icon = Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(5),
          ),
          child: Icon(
            Icons.flag,
            size: 12,
            color: Colors.grey[600],
          ),
        );
        textColor = Colors.black;
        break;
    }

    return Column(
      children: [
        Center(child: icon),
        SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            fontSize: 12,
            fontWeight: status == StationStatus.current ? FontWeight.w600 : FontWeight.w500,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        if (time.isNotEmpty && status != StationStatus.passed)
          Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}