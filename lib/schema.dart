// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

part 'schema.g.dart';

/// Strips qualifier from the revision line if present.
String toRevisionValue(String value) {
  if (value.startsWith('git_revision:')) {
    return value.substring(13);
  }
  return value;
}

@JsonSerializable()
class StatusModel {
  final MiniStatusModel mini_status;
  final String issue_url_base;
  final List<RollModel> recent_rolls;
  final List<ManualRollModel> manual_rolls;
  final String error, throttled_until;

  StatusModel({
    required this.mini_status,
    required this.issue_url_base,
    required this.recent_rolls,
    required this.manual_rolls,
    required this.error,
    required this.throttled_until,
  });

  factory StatusModel.fromJson(Map<String, dynamic> json) =>
      _$StatusModelFromJson(json);
  Map<String, dynamic> toJson() => _$StatusModelToJson(this);
}

@JsonSerializable()
class MiniStatusModel {
  final String roller_id,
      child_name,
      parent_name,
      mode,
      current_roll_rev,
      last_roll_rev;
  final int num_failed, num_behind;

  MiniStatusModel({
    required this.roller_id,
    required this.child_name,
    required this.parent_name,
    required this.mode,
    required this.current_roll_rev,
    required this.last_roll_rev,
    required this.num_failed,
    required this.num_behind,
  });

  factory MiniStatusModel.fromJson(Map<String, dynamic> json) =>
      _$MiniStatusModelFromJson(json);
  Map<String, dynamic> toJson() => _$MiniStatusModelToJson(this);
}

@JsonSerializable()
class RollModel {
  final String id, result, subject, rolling_to, rolling_from, created, modified;
  final List<JobModel> try_jobs;

  get rolling_to_hash {
    return toRevisionValue(rolling_to);
  }

  get rolling_from_hash {
    return toRevisionValue(rolling_from);
  }

  RollModel({
    required this.id,
    required this.result,
    required this.subject,
    required this.rolling_to,
    required this.rolling_from,
    required this.created,
    required this.modified,
    required this.try_jobs,
  });

  factory RollModel.fromJson(Map<String, dynamic> json) =>
      _$RollModelFromJson(json);
  Map<String, dynamic> toJson() => _$RollModelToJson(this);
}

@JsonSerializable()
class ManualRollModel {
  final String id,
      roller_id,
      revision,
      requester,
      result,
      status,
      timestamp,
      url;
  final bool dry_run, no_email, no_resolve_revision;

  ManualRollModel({
    required this.id,
    required this.roller_id,
    required this.revision,
    required this.requester,
    required this.result,
    required this.status,
    required this.timestamp,
    required this.url,
    required this.dry_run,
    required this.no_email,
    required this.no_resolve_revision,
  });

  factory ManualRollModel.fromJson(Map<String, dynamic> json) =>
      _$ManualRollModelFromJson(json);
  Map<String, dynamic> toJson() => _$ManualRollModelToJson(this);
}

@JsonSerializable()
class JobModel {
  final String name, status, result, url, category;

  JobModel({
    required this.name,
    required this.status,
    required this.result,
    required this.url,
    required this.category,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) =>
      _$JobModelFromJson(json);
  Map<String, dynamic> toJson() => _$JobModelToJson(this);
}
