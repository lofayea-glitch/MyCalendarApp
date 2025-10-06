import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:uuid/uuid.dart';
import '../models/event.dart';
import '../services/notification_service.dart';
import '../services/theme_service.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Box? eventsBox;
  Map<String, List<Event>> events = {};
  final uuid = Uuid();

  @override
  void initState() {
    super.initState();
    eventsBox = Hive.box('events');
    _loadEvents();
  }

  void _loadEvents() {
    final raw = eventsBox?.get('events_map');
    if (raw != null) {
      final Map decoded = Map.from(raw);
      events = decoded.map((k, v) => MapEntry(k, List<Event>.from((v as List).map((e) => Event(
        id: e['id'],
        title: e['title'],
        description: e['description'],
        dateTime: DateTime.parse(e['dateTime']),
      )))));
    } else {
      events = {};
    }
    setState((){});
    _saveWidgetData();
  }

  Future<void> _saveEvents() async {
    final Map<String, dynamic> toStore = {};
    events.forEach((k,v){
      toStore[k] = v.map((e)=>{'id':e.id,'title':e.title,'description':e.description,'dateTime':e.dateTime.toIso8601String()}).toList();
    });
    await eventsBox?.put('events_map', toStore);
    _saveWidgetData();
  }

  Future<void> _saveWidgetData() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final count = events[todayKey]?.length ?? 0;
    await prefs.setInt('today_count', count);
    await prefs.setString('today_summary', events[todayKey]?.map((e)=>e.title).join(', ') ?? '');
  }

  List<Event> _getEventsForDay(DateTime day) {
    final key = DateFormat('yyyy-MM-dd').format(day);
    return events[key] ?? [];
  }

  void _addEvent(String title, String description, DateTime when) async {
    final e = Event(id: uuid.v4(), title: title, description: description, dateTime: when);
    final key = DateFormat('yyyy-MM-dd').format(when);
    events.putIfAbsent(key, ()=>[]);
    events[key]!.add(e);
    await _saveEvents();
    // schedule notification 10 minutes before if time is in future
    if (when.isAfter(DateTime.now())) {
      await NotificationService().scheduleNotification(e);
    }
    setState((){});
  }

  void _showAddDialog() {
    final titleCtl = TextEditingController();
    final descCtl = TextEditingController();
    DateTime selected = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, 9, 0);
    showDialog(context: context, builder: (_){
      return AlertDialog(
        title: Text('Add Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtl, decoration: InputDecoration(labelText: 'Title')),
            TextField(controller: descCtl, decoration: InputDecoration(labelText: 'Description')),
            SizedBox(height:8),
            Row(
              children: [
                TextButton(
                  child: Text('Pick time'),
                  onPressed: () async {
                    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(selected));
                    if (t!=null) {
                      setState(()=> selected = DateTime(selected.year, selected.month, selected.day, t.hour, t.minute));
                    }
                  },
                ),
                Text(DateFormat.Hm().format(selected)),
              ],
            )
          ],
        ),
        actions: [
          TextButton(onPressed: ()=>Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(onPressed: (){
            final title = titleCtl.text.trim();
            if (title.isEmpty) return;
            _addEvent(title, descCtl.text.trim(), selected);
            Navigator.pop(context);
          }, child: Text('Save')),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final hijri = HijriCalendar.fromDate(_focusedDay);
    return Scaffold(
      appBar: AppBar(
        title: Text('تقويم • Calendar'),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: (){
              Provider.of<ThemeService>(context, listen:false).toggle();
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(child: Text('Hijri: ${hijri.toFormat("dd MMMM yyyy")}', style: TextStyle(fontSize:16))),
                Text(DateFormat.yMMMMd().format(_focusedDay)),
              ],
            ),
          ),
          TableCalendar(
            firstDay: DateTime.utc(2000,1,1),
            lastDay: DateTime.utc(2100,12,31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
            onDaySelected: (selectedDay, focusedDay) {
              setState((){
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getEventsForDay,
          ),
          const SizedBox(height:8),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(12),
              children: _getEventsForDay(_selectedDay).map((e){
                return Card(
                  child: ListTile(
                    title: Text(e.title),
                    subtitle: Text('${DateFormat.Hm().format(e.dateTime)} • ${e.description}'),
                    trailing: IconButton(icon: Icon(Icons.delete), onPressed: (){
                      final key = DateFormat('yyyy-MM-dd').format(e.dateTime);
                      events[key]?.removeWhere((it)=>it.id==e.id);
                      _saveEvents();
                      setState(()=>{});
                    }),
                  ),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}
