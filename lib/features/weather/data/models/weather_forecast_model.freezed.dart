// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weather_forecast_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WeatherForecastModel {

 List<HourlyForecastPointModel> get hourly; List<DailyForecastPointModel> get daily;
/// Create a copy of WeatherForecastModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeatherForecastModelCopyWith<WeatherForecastModel> get copyWith => _$WeatherForecastModelCopyWithImpl<WeatherForecastModel>(this as WeatherForecastModel, _$identity);

  /// Serializes this WeatherForecastModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeatherForecastModel&&const DeepCollectionEquality().equals(other.hourly, hourly)&&const DeepCollectionEquality().equals(other.daily, daily));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(hourly),const DeepCollectionEquality().hash(daily));

@override
String toString() {
  return 'WeatherForecastModel(hourly: $hourly, daily: $daily)';
}


}

/// @nodoc
abstract mixin class $WeatherForecastModelCopyWith<$Res>  {
  factory $WeatherForecastModelCopyWith(WeatherForecastModel value, $Res Function(WeatherForecastModel) _then) = _$WeatherForecastModelCopyWithImpl;
@useResult
$Res call({
 List<HourlyForecastPointModel> hourly, List<DailyForecastPointModel> daily
});




}
/// @nodoc
class _$WeatherForecastModelCopyWithImpl<$Res>
    implements $WeatherForecastModelCopyWith<$Res> {
  _$WeatherForecastModelCopyWithImpl(this._self, this._then);

  final WeatherForecastModel _self;
  final $Res Function(WeatherForecastModel) _then;

/// Create a copy of WeatherForecastModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hourly = null,Object? daily = null,}) {
  return _then(_self.copyWith(
hourly: null == hourly ? _self.hourly : hourly // ignore: cast_nullable_to_non_nullable
as List<HourlyForecastPointModel>,daily: null == daily ? _self.daily : daily // ignore: cast_nullable_to_non_nullable
as List<DailyForecastPointModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [WeatherForecastModel].
extension WeatherForecastModelPatterns on WeatherForecastModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeatherForecastModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeatherForecastModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeatherForecastModel value)  $default,){
final _that = this;
switch (_that) {
case _WeatherForecastModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeatherForecastModel value)?  $default,){
final _that = this;
switch (_that) {
case _WeatherForecastModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<HourlyForecastPointModel> hourly,  List<DailyForecastPointModel> daily)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeatherForecastModel() when $default != null:
return $default(_that.hourly,_that.daily);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<HourlyForecastPointModel> hourly,  List<DailyForecastPointModel> daily)  $default,) {final _that = this;
switch (_that) {
case _WeatherForecastModel():
return $default(_that.hourly,_that.daily);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<HourlyForecastPointModel> hourly,  List<DailyForecastPointModel> daily)?  $default,) {final _that = this;
switch (_that) {
case _WeatherForecastModel() when $default != null:
return $default(_that.hourly,_that.daily);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WeatherForecastModel extends WeatherForecastModel {
  const _WeatherForecastModel({required final  List<HourlyForecastPointModel> hourly, required final  List<DailyForecastPointModel> daily}): _hourly = hourly,_daily = daily,super._();
  factory _WeatherForecastModel.fromJson(Map<String, dynamic> json) => _$WeatherForecastModelFromJson(json);

 final  List<HourlyForecastPointModel> _hourly;
@override List<HourlyForecastPointModel> get hourly {
  if (_hourly is EqualUnmodifiableListView) return _hourly;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hourly);
}

 final  List<DailyForecastPointModel> _daily;
@override List<DailyForecastPointModel> get daily {
  if (_daily is EqualUnmodifiableListView) return _daily;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_daily);
}


/// Create a copy of WeatherForecastModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeatherForecastModelCopyWith<_WeatherForecastModel> get copyWith => __$WeatherForecastModelCopyWithImpl<_WeatherForecastModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WeatherForecastModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeatherForecastModel&&const DeepCollectionEquality().equals(other._hourly, _hourly)&&const DeepCollectionEquality().equals(other._daily, _daily));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_hourly),const DeepCollectionEquality().hash(_daily));

@override
String toString() {
  return 'WeatherForecastModel(hourly: $hourly, daily: $daily)';
}


}

/// @nodoc
abstract mixin class _$WeatherForecastModelCopyWith<$Res> implements $WeatherForecastModelCopyWith<$Res> {
  factory _$WeatherForecastModelCopyWith(_WeatherForecastModel value, $Res Function(_WeatherForecastModel) _then) = __$WeatherForecastModelCopyWithImpl;
@override @useResult
$Res call({
 List<HourlyForecastPointModel> hourly, List<DailyForecastPointModel> daily
});




}
/// @nodoc
class __$WeatherForecastModelCopyWithImpl<$Res>
    implements _$WeatherForecastModelCopyWith<$Res> {
  __$WeatherForecastModelCopyWithImpl(this._self, this._then);

  final _WeatherForecastModel _self;
  final $Res Function(_WeatherForecastModel) _then;

/// Create a copy of WeatherForecastModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hourly = null,Object? daily = null,}) {
  return _then(_WeatherForecastModel(
hourly: null == hourly ? _self._hourly : hourly // ignore: cast_nullable_to_non_nullable
as List<HourlyForecastPointModel>,daily: null == daily ? _self._daily : daily // ignore: cast_nullable_to_non_nullable
as List<DailyForecastPointModel>,
  ));
}


}

// dart format on
