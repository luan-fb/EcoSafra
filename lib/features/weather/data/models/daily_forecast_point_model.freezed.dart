// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_forecast_point_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DailyForecastPointModel {

 DateTime get date; double get precipitationSum; int get precipitationProbabilityMax; double get temperatureMax; double get temperatureMin; double get windSpeedMax; int get weatherCode;
/// Create a copy of DailyForecastPointModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyForecastPointModelCopyWith<DailyForecastPointModel> get copyWith => _$DailyForecastPointModelCopyWithImpl<DailyForecastPointModel>(this as DailyForecastPointModel, _$identity);

  /// Serializes this DailyForecastPointModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyForecastPointModel&&(identical(other.date, date) || other.date == date)&&(identical(other.precipitationSum, precipitationSum) || other.precipitationSum == precipitationSum)&&(identical(other.precipitationProbabilityMax, precipitationProbabilityMax) || other.precipitationProbabilityMax == precipitationProbabilityMax)&&(identical(other.temperatureMax, temperatureMax) || other.temperatureMax == temperatureMax)&&(identical(other.temperatureMin, temperatureMin) || other.temperatureMin == temperatureMin)&&(identical(other.windSpeedMax, windSpeedMax) || other.windSpeedMax == windSpeedMax)&&(identical(other.weatherCode, weatherCode) || other.weatherCode == weatherCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,precipitationSum,precipitationProbabilityMax,temperatureMax,temperatureMin,windSpeedMax,weatherCode);

@override
String toString() {
  return 'DailyForecastPointModel(date: $date, precipitationSum: $precipitationSum, precipitationProbabilityMax: $precipitationProbabilityMax, temperatureMax: $temperatureMax, temperatureMin: $temperatureMin, windSpeedMax: $windSpeedMax, weatherCode: $weatherCode)';
}


}

/// @nodoc
abstract mixin class $DailyForecastPointModelCopyWith<$Res>  {
  factory $DailyForecastPointModelCopyWith(DailyForecastPointModel value, $Res Function(DailyForecastPointModel) _then) = _$DailyForecastPointModelCopyWithImpl;
@useResult
$Res call({
 DateTime date, double precipitationSum, int precipitationProbabilityMax, double temperatureMax, double temperatureMin, double windSpeedMax, int weatherCode
});




}
/// @nodoc
class _$DailyForecastPointModelCopyWithImpl<$Res>
    implements $DailyForecastPointModelCopyWith<$Res> {
  _$DailyForecastPointModelCopyWithImpl(this._self, this._then);

  final DailyForecastPointModel _self;
  final $Res Function(DailyForecastPointModel) _then;

/// Create a copy of DailyForecastPointModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? precipitationSum = null,Object? precipitationProbabilityMax = null,Object? temperatureMax = null,Object? temperatureMin = null,Object? windSpeedMax = null,Object? weatherCode = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,precipitationSum: null == precipitationSum ? _self.precipitationSum : precipitationSum // ignore: cast_nullable_to_non_nullable
as double,precipitationProbabilityMax: null == precipitationProbabilityMax ? _self.precipitationProbabilityMax : precipitationProbabilityMax // ignore: cast_nullable_to_non_nullable
as int,temperatureMax: null == temperatureMax ? _self.temperatureMax : temperatureMax // ignore: cast_nullable_to_non_nullable
as double,temperatureMin: null == temperatureMin ? _self.temperatureMin : temperatureMin // ignore: cast_nullable_to_non_nullable
as double,windSpeedMax: null == windSpeedMax ? _self.windSpeedMax : windSpeedMax // ignore: cast_nullable_to_non_nullable
as double,weatherCode: null == weatherCode ? _self.weatherCode : weatherCode // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyForecastPointModel].
extension DailyForecastPointModelPatterns on DailyForecastPointModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyForecastPointModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyForecastPointModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyForecastPointModel value)  $default,){
final _that = this;
switch (_that) {
case _DailyForecastPointModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyForecastPointModel value)?  $default,){
final _that = this;
switch (_that) {
case _DailyForecastPointModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  double precipitationSum,  int precipitationProbabilityMax,  double temperatureMax,  double temperatureMin,  double windSpeedMax,  int weatherCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyForecastPointModel() when $default != null:
return $default(_that.date,_that.precipitationSum,_that.precipitationProbabilityMax,_that.temperatureMax,_that.temperatureMin,_that.windSpeedMax,_that.weatherCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  double precipitationSum,  int precipitationProbabilityMax,  double temperatureMax,  double temperatureMin,  double windSpeedMax,  int weatherCode)  $default,) {final _that = this;
switch (_that) {
case _DailyForecastPointModel():
return $default(_that.date,_that.precipitationSum,_that.precipitationProbabilityMax,_that.temperatureMax,_that.temperatureMin,_that.windSpeedMax,_that.weatherCode);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  double precipitationSum,  int precipitationProbabilityMax,  double temperatureMax,  double temperatureMin,  double windSpeedMax,  int weatherCode)?  $default,) {final _that = this;
switch (_that) {
case _DailyForecastPointModel() when $default != null:
return $default(_that.date,_that.precipitationSum,_that.precipitationProbabilityMax,_that.temperatureMax,_that.temperatureMin,_that.windSpeedMax,_that.weatherCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DailyForecastPointModel extends DailyForecastPointModel {
  const _DailyForecastPointModel({required this.date, required this.precipitationSum, required this.precipitationProbabilityMax, required this.temperatureMax, required this.temperatureMin, required this.windSpeedMax, required this.weatherCode}): super._();
  factory _DailyForecastPointModel.fromJson(Map<String, dynamic> json) => _$DailyForecastPointModelFromJson(json);

@override final  DateTime date;
@override final  double precipitationSum;
@override final  int precipitationProbabilityMax;
@override final  double temperatureMax;
@override final  double temperatureMin;
@override final  double windSpeedMax;
@override final  int weatherCode;

/// Create a copy of DailyForecastPointModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyForecastPointModelCopyWith<_DailyForecastPointModel> get copyWith => __$DailyForecastPointModelCopyWithImpl<_DailyForecastPointModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DailyForecastPointModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyForecastPointModel&&(identical(other.date, date) || other.date == date)&&(identical(other.precipitationSum, precipitationSum) || other.precipitationSum == precipitationSum)&&(identical(other.precipitationProbabilityMax, precipitationProbabilityMax) || other.precipitationProbabilityMax == precipitationProbabilityMax)&&(identical(other.temperatureMax, temperatureMax) || other.temperatureMax == temperatureMax)&&(identical(other.temperatureMin, temperatureMin) || other.temperatureMin == temperatureMin)&&(identical(other.windSpeedMax, windSpeedMax) || other.windSpeedMax == windSpeedMax)&&(identical(other.weatherCode, weatherCode) || other.weatherCode == weatherCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,precipitationSum,precipitationProbabilityMax,temperatureMax,temperatureMin,windSpeedMax,weatherCode);

@override
String toString() {
  return 'DailyForecastPointModel(date: $date, precipitationSum: $precipitationSum, precipitationProbabilityMax: $precipitationProbabilityMax, temperatureMax: $temperatureMax, temperatureMin: $temperatureMin, windSpeedMax: $windSpeedMax, weatherCode: $weatherCode)';
}


}

/// @nodoc
abstract mixin class _$DailyForecastPointModelCopyWith<$Res> implements $DailyForecastPointModelCopyWith<$Res> {
  factory _$DailyForecastPointModelCopyWith(_DailyForecastPointModel value, $Res Function(_DailyForecastPointModel) _then) = __$DailyForecastPointModelCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, double precipitationSum, int precipitationProbabilityMax, double temperatureMax, double temperatureMin, double windSpeedMax, int weatherCode
});




}
/// @nodoc
class __$DailyForecastPointModelCopyWithImpl<$Res>
    implements _$DailyForecastPointModelCopyWith<$Res> {
  __$DailyForecastPointModelCopyWithImpl(this._self, this._then);

  final _DailyForecastPointModel _self;
  final $Res Function(_DailyForecastPointModel) _then;

/// Create a copy of DailyForecastPointModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? precipitationSum = null,Object? precipitationProbabilityMax = null,Object? temperatureMax = null,Object? temperatureMin = null,Object? windSpeedMax = null,Object? weatherCode = null,}) {
  return _then(_DailyForecastPointModel(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,precipitationSum: null == precipitationSum ? _self.precipitationSum : precipitationSum // ignore: cast_nullable_to_non_nullable
as double,precipitationProbabilityMax: null == precipitationProbabilityMax ? _self.precipitationProbabilityMax : precipitationProbabilityMax // ignore: cast_nullable_to_non_nullable
as int,temperatureMax: null == temperatureMax ? _self.temperatureMax : temperatureMax // ignore: cast_nullable_to_non_nullable
as double,temperatureMin: null == temperatureMin ? _self.temperatureMin : temperatureMin // ignore: cast_nullable_to_non_nullable
as double,windSpeedMax: null == windSpeedMax ? _self.windSpeedMax : windSpeedMax // ignore: cast_nullable_to_non_nullable
as double,weatherCode: null == weatherCode ? _self.weatherCode : weatherCode // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
