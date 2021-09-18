class PassDataModel {
  String busJobPoiId;
  String status;
  String locationName;
  int passengerCount;
  int passengerCountUsed;

  PassDataModel(this.busJobPoiId, this.status, this.locationName,
      this.passengerCount, this.passengerCountUsed);
}
