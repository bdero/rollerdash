// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatusModel _$StatusModelFromJson(Map<String, dynamic> json) => StatusModel(
      mini_status:
          MiniStatusModel.fromJson(json['mini_status'] as Map<String, dynamic>),
      issue_url_base: json['issue_url_base'] as String,
      recent_rolls: (json['recent_rolls'] as List<dynamic>)
          .map((e) => RollModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      manual_rolls: (json['manual_rolls'] as List<dynamic>)
          .map((e) => ManualRollModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      error: json['error'] as String,
      throttled_until: json['throttled_until'] as String,
    );

Map<String, dynamic> _$StatusModelToJson(StatusModel instance) =>
    <String, dynamic>{
      'mini_status': instance.mini_status,
      'issue_url_base': instance.issue_url_base,
      'recent_rolls': instance.recent_rolls,
      'manual_rolls': instance.manual_rolls,
      'error': instance.error,
      'throttled_until': instance.throttled_until,
    };

MiniStatusModel _$MiniStatusModelFromJson(Map<String, dynamic> json) =>
    MiniStatusModel(
      roller_id: json['roller_id'] as String,
      child_name: json['child_name'] as String,
      parent_name: json['parent_name'] as String,
      mode: json['mode'] as String,
      current_roll_rev: json['current_roll_rev'] as String,
      last_roll_rev: json['last_roll_rev'] as String,
      num_failed: json['num_failed'] as int,
      num_behind: json['num_behind'] as int,
    );

Map<String, dynamic> _$MiniStatusModelToJson(MiniStatusModel instance) =>
    <String, dynamic>{
      'roller_id': instance.roller_id,
      'child_name': instance.child_name,
      'parent_name': instance.parent_name,
      'mode': instance.mode,
      'current_roll_rev': instance.current_roll_rev,
      'last_roll_rev': instance.last_roll_rev,
      'num_failed': instance.num_failed,
      'num_behind': instance.num_behind,
    };

RollModel _$RollModelFromJson(Map<String, dynamic> json) => RollModel(
      id: json['id'] as String,
      result: json['result'] as String,
      subject: json['subject'] as String,
      rolling_to: json['rolling_to'] as String,
      rolling_from: json['rolling_from'] as String,
      created: json['created'] as String,
      modified: json['modified'] as String,
      try_jobs: (json['try_jobs'] as List<dynamic>)
          .map((e) => JobModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RollModelToJson(RollModel instance) => <String, dynamic>{
      'id': instance.id,
      'result': instance.result,
      'subject': instance.subject,
      'rolling_to': instance.rolling_to,
      'rolling_from': instance.rolling_from,
      'created': instance.created,
      'modified': instance.modified,
      'try_jobs': instance.try_jobs,
    };

ManualRollModel _$ManualRollModelFromJson(Map<String, dynamic> json) =>
    ManualRollModel(
      id: json['id'] as String,
      roller_id: json['roller_id'] as String,
      revision: json['revision'] as String,
      requester: json['requester'] as String,
      result: json['result'] as String,
      status: json['status'] as String,
      timestamp: json['timestamp'] as String,
      url: json['url'] as String,
      dry_run: json['dry_run'] as bool,
      no_email: json['no_email'] as bool,
      no_resolve_revision: json['no_resolve_revision'] as bool,
    );

Map<String, dynamic> _$ManualRollModelToJson(ManualRollModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'roller_id': instance.roller_id,
      'revision': instance.revision,
      'requester': instance.requester,
      'result': instance.result,
      'status': instance.status,
      'timestamp': instance.timestamp,
      'url': instance.url,
      'dry_run': instance.dry_run,
      'no_email': instance.no_email,
      'no_resolve_revision': instance.no_resolve_revision,
    };

JobModel _$JobModelFromJson(Map<String, dynamic> json) => JobModel(
      name: json['name'] as String,
      status: json['status'] as String,
      result: json['result'] as String,
      url: json['url'] as String,
      category: json['category'] as String,
    );

Map<String, dynamic> _$JobModelToJson(JobModel instance) => <String, dynamic>{
      'name': instance.name,
      'status': instance.status,
      'result': instance.result,
      'url': instance.url,
      'category': instance.category,
    };
