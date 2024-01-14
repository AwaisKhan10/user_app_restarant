class DateMonthBody{
  int? date;
  int? month;
  DateMonthBody({required this.date, required this.month});

  DateMonthBody.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    month = json['month'];
  }
  //
  // Map<String, int> toJson() {
  //   final Map<String, int> data = <String, int>{};
  //   data['date'] = date!;
  //   data['month'] = month!;
  //   return data;
  // }
}