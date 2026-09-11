// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hourly_forecast_point_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HourlyForecastPointModel {

 DateTime get time; double get precipitation; int get precipitationProbability; double get temperature; int get relativeHumidity; double get windSpeed; double? get soilMoisture;
/// Create a copy of HourlyForecastPointModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HourlyForecastPointModelCopyWith<HourlyForecastPointModel> get copyWith => _$HourlyForecastPointModelCopyWithImpl<HourlyForecastPointModel>(this as HourlyForecastPointModel, _$identity);

  /// Serializes this HourlyForecastPointModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HourlyForecastPointModel&&(identical(other.time, time) || other.time == time)&&(identical(other.precipitation, precipitation) || other.precipitation == precipitation)&&(identical(other.precipitationProbability, precipitationProbability) || other.precipitationProbability == precipitationProbability)&&(identical(other.temperature, temperature) || other.temperature == temperature)&&(identical(other.relativeHumidity, relativeHumidity) || other.relativeHumidity == relativeHumidity)&&(identical(other.windSpeed, windSpeed) || other.windSpeed == windSpeed)&&(identical(other.soilMoisture, soilMoisture) || other.soilMoisture == soilMoisture));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,time,precipitation,precipitationProbability,temperature,relativeHumidity,windSpeed,soilMoisture);

@override
String toString() {
  return 'HourlyForecastPointModel(time: $time, precipitation: $precipitation, precipitationProbability: $precipitationProbability, temperature: $temperature, relativeHumidity: $relativeHumidity, windSpeed: $windSpeed, soilMoisture: $soilMoisture)';
}


}

/// @nodoc
abstract mixin class $HourlyForecastPointModelCopyWith<$Res>  {
  factory $HourlyForecastPointModelCopyWith(HourlyForecastPointModel value, $Res Function(HourlyForecastPointModel) _then) = _$HourlyForecastPointModelCopyWithImpl;
@useResult
$Res call({
 DateTime time, double precipitation, int precipitationProbability, double temperature, int relativeHumidity, double windSpeed, double? soilMoisture
});




}
/// @nodoc
class _$HourlyForecastPointModelCopyWithImpl<$Res>
    implements $HourlyForecastPointModelCopyWith<$Res> {
  _$HourlyForecastPointModelCopyWithImpl(this._self, this._then);

  final HourlyForecastPointModel _self;
  final $Res Function(HourlyForecastPointModel) _then;

/// Create a copy of HourlyForecastPointModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? time = null,Object? precipitation = null,Object? precipitationProbability = null,Object? temperature = null,Object? relativeHumidity = null,Object? windSpeed = null,Object? soilMoisture = freezed,}) {
  return _then(_self.copyWith(
time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime,precipitation: null == precipitation ? _self.precipitation : precipitation // ignore: cast_nullable_to_non_nullable
as double,precipitationProbability: null == precipitationProbability ? _self.precipitationProbability : precipitationProbability // ignore: cast_nullable_to_non_nullable
as int,temperature: null == temperature ? _self.temperature : temperature // ignore: cast_nullable_to_non_nullable
as double,relativeHumidity: null == relativeHumidity ? _self.relativeHumidity : relativeHumidity // ignore: cast_nullable_to_non_nullable
as int,windSpeed: null == windSpeed ? _self.windSpeed : windSpeed // ignore: cast_nullable_to_non_nullable
as double,soilMoisture: freezed == soilMoisture ? _self.soilMoisture : soilMoisture // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [HourlyForecastPointModel].
extension HourlyForecastPointModelPatterns on HourlyForecastPointModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HourlyForecastPointModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HourlyForecastPointModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HourlyForecastPointModel value)  $default,){
final _that = this;
switch (_that) {
case _HourlyForecastPointModel():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HourlyForecastPointModel value)?  $default,){
final _that = this;
switch (_that) {
case _HourlyForecastPointModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime time,  double precipitation,  int precipitationProbability,  double temperature,  int relativeHumidity,  double windSpeed,  double? soilMoisture)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HourlyForecastPointModel() when $default != null:
return $default(_that.time,_that.precipitation,_that.precipitationProbability,_that.temperature,_that.relativeHumidity,_that.windSpeed,_that.soilMoisture);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime time,  double precipitation,  int precipitationProbability,  double temperature,  int relativeHumidity,  double windSpeed,  double? soilMoisture)  $default,) {final _that = this;
switch (_that) {
case _HourlyForecastPointModel():
return $default(_that.time,_that.precipitation,_that.precipitationProbability,_that.temperature,_that.relativeHumidity,_that.windSpeed,_that.soilMoisture);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime time,  double precipitation,  int precipitationProbability,  double temperature,  int relativeHumidity,  double windSpeed,  double? soilMoisture)?  $default,) {final _that = this;
switch (_that) {
case _HourlyForecastPointModel() when $default != null:
return $default(_that.time,_that.precipitation,_that.precipitationProbability,_that.temperature,_that.relativeHumidity,_that.windSpeed,_that.soilMoisture);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HourlyForecastPointModel extends HourlyForecastPointModel {
  const _HourlyForecastPointModel({required this.time, required this.precipitation, required this.precipitationProbability, required this.temperature, required this.relativeHumidity, required this.windSpeed, this.soilMoisture}): super._();
  factory _HourlyForecastPointModel.fromJson(Map<String, dynamic> json) => _$HourlyForecastPointModelFromJson(json);

@override final  DateTime time;
@override final  double precipitation;
@override final  int precipitationProbability;
@override final  double temperature;
@override final  int relativeHumidity;
@override final  double windSpeed;
@override final  double? soilMoisture;

/// Create a copy of HourlyForecastPointModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HourlyForecastPointModelCopyWith<_HourlyForecastPointModel> get copyWith => __$HourlyForecastPointModelCopyWithImpl<_HourlyForecastPointModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HourlyForecastPointModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HourlyForecastPointModel&&(identical(other.time, time) || other.time == time)&&(identical(other.precipitation, precipitation) || other.precipitation == precipitation)&&(identical(other.precipitationProbability, precipitationProbability) || other.precipitationProbability == precipitationProbability)&&(identical(other.temperature, temperature) || other.temperature == temperature)&&(identical(other.relativeHumidity, relativeHumidity) || other.relativeHumidity == relativeHumidity)&&(identical(other.windSpeed, windSpeed) || other.windSpeed == windSpeed)&&(identical(other.soilMoisture, soilMoisture) || other.soilMoisture == soilMoisture));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,time,precipitation,precipitationProbability,temperature,relativeHumidity,windSpeed,soilMoisture);

@override
String toString() {
  return 'HourlyForecastPointModel(time: $time, precipitation: $precipitation, precipitationProbability: $precipitationProbability, temperature: $temperature, relativeHumidity: $relativeHumidity, windSpeed: $windSpeed, soilMoisture: $soilMoisture)';
}


}

/// @nodoc
abstract mixin class _$HourlyForecastPointModelCopyWith<$Res> implements $HourlyForecastPointModelCopyWith<$Res> {
  factory _$HourlyForecastPointModelCopyWith(_HourlyForecastPointModel value, $Res Function(_HourlyForecastPointModel) _then) = __$HourlyForecastPointModelCopyWithImpl;
@override @useResult
$Res call({
 DateTime time, double precipitation, int precipitationProbability, double temperature, int relativeHumidity, double windSpeed, double? soilMoisture
});




}
/// @nodoc
class __$HourlyForecastPointModelCopyWithImpl<$Res>
    implements _$HourlyForecastPointModelCopyWith<$Res> {
  __$HourlyForecastPointModelCopyWithImpl(this._self, this._then);

  final _HourlyForecastPointModel _self;
  final $Res Function(_HourlyForecastPointModel) _then;

/// Create a copy of HourlyForecastPointModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? time = null,Object? precipitation = null,Object? precipitationProbability = null,Object? temperature = null,Object? relativeHumidity = null,Object? windSpeed = null,Object? soilMoisture = freezed,}) {
  return _then(_HourlyForecastPointModel(
time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime,precipitation: null == precipitation ? _self.precipitation : precipitation // ignore: cast_nullable_to_non_nullable
as double,precipitationProbability: null == precipitationProbability ? _self.precipitationProbability : precipitationProbability // ignore: cast_nullable_to_non_nullable
as int,temperature: null == temperature ? _self.temperature : temperature // ignore: cast_nullable_to_non_nullable
as double,relativeHumidity: null == relativeHumidity ? _self.relativeHumidity : relativeHumidity // ignore: cast_nullable_to_non_nullable
as int,windSpeed: null == windSpeed ? _self.windSpeed : windSpeed // ignore: cast_nullable_to_non_nullable
as double,soilMoisture: freezed == soilMoisture ? _self.soilMoisture : soilMoisture // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
