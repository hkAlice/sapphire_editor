import 'dart:async';

import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:sapphire_editor/models/simulator/simulated_event.dart';
import 'package:sapphire_editor/models/simulator/simulation_track_marker.dart';
import 'package:sapphire_editor/models/timeline/condition/types/combatstate_condition_model.dart';
import 'package:sapphire_editor/services/simulator_signal.dart';
import 'package:sapphire_editor/services/timeline_signal_registry.dart';
import 'package:sapphire_editor/widgets/page_header_widget.dart';

class SimulatorView extends StatefulWidget {
  const SimulatorView({super.key});

  @override
  State<SimulatorView> createState() => _SimulatorViewState();
}

class _SimulatorViewState extends State<SimulatorView>
    with AutomaticKeepAliveClientMixin<SimulatorView> {
  SimulatorSignal? _signal;
  Timer? _signalPollTimer;

  double? _pendingHpPct;
  int? _manualPhaseId;

  final TextEditingController _actionIdController =
      TextEditingController(text: '6116');
  final TextEditingController _interruptActionIdController =
      TextEditingController(text: '6116');
  final TextEditingController _eObjNameController =
      TextEditingController(text: 'Lever');
  final TextEditingController _directorVarIndexController =
      TextEditingController(text: '8');
  final TextEditingController _directorVarValueController =
      TextEditingController(text: '1');

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tryInitializeSignal();

    _signalPollTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      _tryInitializeSignal();
      if(_signal != null) {
        _signalPollTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _signalPollTimer?.cancel();
    _signal?.dispose();
    _actionIdController.dispose();
    _interruptActionIdController.dispose();
    _eObjNameController.dispose();
    _directorVarIndexController.dispose();
    _directorVarValueController.dispose();
    super.dispose();
  }

  void _tryInitializeSignal() {
    if(_signal != null) {
      return;
    }

    final timelineSignal = TimelineSignalRegistry.instance.signal;
    if(timelineSignal == null) {
      return;
    }

    setState(() {
      _signal = SimulatorSignal(timelineSignal);
    });
  }

  int? _parseInt(String value) {
    final trimmed = value.trim();
    if(trimmed.isEmpty) {
      return null;
    }

    if(trimmed.startsWith('0x') || trimmed.startsWith('0X')) {
      return int.tryParse(trimmed.substring(2), radix: 16);
    }

    return int.tryParse(trimmed);
  }

  String _formatDuration(int ms) {
    final totalSeconds = ms ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final millis = ms % 1000;
    return '$minutes:${seconds.toString().padLeft(2, '0')}.${millis.toString().padLeft(3, '0')}';
  }

  Color _eventColor(BuildContext context, SimulatedEventType type) {
    final scheme = Theme.of(context).colorScheme;
    return switch(type) {
      SimulatedEventType.phaseEnter => scheme.primary,
      SimulatedEventType.phaseExit => scheme.secondary,
      SimulatedEventType.phaseTransition => scheme.tertiary,
      SimulatedEventType.triggerMatched => scheme.secondary,
      SimulatedEventType.timepoint => scheme.primary,
      SimulatedEventType.manual => scheme.tertiary,
      SimulatedEventType.info => scheme.outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final signal = _signal;
    if(signal == null) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              PageHeaderWidget(
                title: 'Timeline Simulator',
                subtitle:
                    'Waiting for Timeline Editor state before initializing simulator.',
                heading: const Icon(Icons.smart_display_rounded, size: 56),
              ),
              const Divider(),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                          'Open the Timeline Editor first to load a timeline.'),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _tryInitializeSignal,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Watch((context) {
          final simState = signal.state.value;
          final selectedActorId = signal.selectedActorId.value;
          final selectedActor = signal.selectedActorState;
          final actorPhases = signal.phasesForSelectedActor();

          final hpValue = _pendingHpPct ?? selectedActor?.hpPct ?? 100;
          final phaseSelection = actorPhases
                  .where((phase) => phase.id == _manualPhaseId)
                  .isNotEmpty
              ? _manualPhaseId
              : selectedActor?.currentPhaseId;

          return Column(
            children: [
              PageHeaderWidget(
                title: 'Timeline Simulator',
                subtitle:
                    'Play through triggers, phases, and schedules safely.',
                heading: const Icon(Icons.smart_display_rounded, size: 56),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilledButton.icon(
                      onPressed: signal.togglePlay,
                      icon: Icon(simState.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded),
                      label: Text(simState.isPlaying ? 'Pause' : 'Play'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => signal.stepForward(1000),
                      icon: const Icon(Icons.skip_next_rounded),
                      label: const Text('Step +1s'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: signal.reset,
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text('Reset'),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 7,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Time ${_formatDuration(simState.elapsedMs)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        const SizedBox(width: 12),
                                        Chip(
                                          avatar: Icon(
                                            simState.isInSyncWithEditor
                                                ? Icons.check_circle_outline
                                                : Icons.warning_amber_rounded,
                                            size: 18,
                                          ),
                                          label: Text(simState.syncStatus),
                                        ),
                                        const Spacer(),
                                        OutlinedButton.icon(
                                          onPressed: signal.resyncNow,
                                          icon: const Icon(Icons.sync_rounded),
                                          label: const Text('Resync'),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      height: 130,
                                      child: _TimelineTrack(
                                        nowMs: simState.elapsedMs,
                                        markers: simState.trackMarkers,
                                        colorForType: (type) =>
                                            _eventColor(context, type),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: simState.events.isEmpty
                                      ? const Center(
                                          child:
                                              Text('No simulated events yet.'),
                                        )
                                      : ListView.builder(
                                          itemCount: simState.events.length,
                                          itemBuilder: (context, index) {
                                            final event = simState.events[
                                                simState.events.length -
                                                    1 -
                                                    index];
                                            return ListTile(
                                              dense: true,
                                              leading: Text(event.timeLabel),
                                              title: Text(event.message),
                                              subtitle: Text(
                                                '${event.actorName} • ${event.phaseName}',
                                              ),
                                              trailing: Icon(
                                                Icons
                                                    .fiber_manual_record_rounded,
                                                size: 12,
                                                color: _eventColor(
                                                  context,
                                                  event.type,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    SizedBox(
                      width: 420,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'State Controls',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<int>(
                              key: ValueKey<String>(
                                'actor-$selectedActorId',
                              ),
                              initialValue: selectedActorId,
                              decoration: const InputDecoration(
                                labelText: 'Actor',
                              ),
                              items: simState.actors
                                  .map(
                                    (actor) => DropdownMenuItem<int>(
                                      value: actor.actorId,
                                      child: Text(actor.actorName),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                signal.selectActor(value);
                                setState(() {
                                  _pendingHpPct = null;
                                  _manualPhaseId = null;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            if(selectedActor != null)
                              Text(
                                'Current: ${selectedActor.currentPhaseName} (#${selectedActor.currentPhaseId})',
                              ),
                            const SizedBox(height: 8),
                            Text('HP% (${hpValue.toStringAsFixed(1)})'),
                            Slider(
                              value: hpValue,
                              min: 0,
                              max: 100,
                              onChanged: selectedActor == null
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _pendingHpPct = value;
                                      });
                                    },
                              onChangeEnd: selectedActor == null
                                  ? null
                                  : (value) {
                                      signal.setSelectedActorHpPct(value);
                                      setState(() {
                                        _pendingHpPct = null;
                                      });
                                    },
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<ActorCombatState>(
                              key: ValueKey<ActorCombatState?>(
                                selectedActor?.combatState,
                              ),
                              initialValue: selectedActor?.combatState,
                              decoration: const InputDecoration(
                                labelText: 'Combat State',
                              ),
                              items: ActorCombatState.values
                                  .map(
                                    (state) => DropdownMenuItem(
                                      value: state,
                                      child: Text(state.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: selectedActor == null
                                  ? null
                                  : (value) {
                                      if(value != null) {
                                        signal.setSelectedActorCombatState(
                                          value,
                                        );
                                      }
                                    },
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Auto HP Drain (%/sec): ${simState.config.dpsPctPerSecond.toStringAsFixed(2)}',
                            ),
                            Slider(
                              value: simState.config.dpsPctPerSecond,
                              min: 0,
                              max: 10,
                              onChanged: signal.setDpsPctPerSecond,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Playback Speed: ${simState.config.speedMultiplier.toStringAsFixed(2)}x',
                            ),
                            Slider(
                              value: simState.config.speedMultiplier,
                              min: 0.25,
                              max: 4,
                              onChanged: signal.setSpeedMultiplier,
                            ),
                            const Divider(height: 28),
                            Text(
                              'Manual Injections',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _actionIdController,
                                    decoration: const InputDecoration(
                                      labelText: 'Action ID',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: () {
                                    final id =
                                        _parseInt(_actionIdController.text);
                                    if(id != null) {
                                      signal.injectSelectedActorAction(id);
                                    }
                                  },
                                  child: const Text('Inject Cast'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _interruptActionIdController,
                                    decoration: const InputDecoration(
                                      labelText: 'Interrupted Action ID',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: () {
                                    final id = _parseInt(
                                        _interruptActionIdController.text);
                                    if(id != null) {
                                      signal
                                          .injectSelectedActorInterruptedAction(
                                              id);
                                    }
                                  },
                                  child: const Text('Inject Interrupt'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _eObjNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'EObj Name',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: () {
                                    signal.injectEObjInteraction(
                                      _eObjNameController.text,
                                    );
                                  },
                                  child: const Text('Inject EObj'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _directorVarIndexController,
                                    decoration: const InputDecoration(
                                      labelText: 'Director Var Index',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _directorVarValueController,
                                    decoration: const InputDecoration(
                                      labelText: 'Value',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: () {
                                    final index = _parseInt(
                                        _directorVarIndexController.text);
                                    final value = _parseInt(
                                        _directorVarValueController.text);
                                    if(index != null && value != null) {
                                      signal.setSelectedActorDirectorVar(
                                        index,
                                        value,
                                      );
                                    }
                                  },
                                  child: const Text('Set Var'),
                                ),
                              ],
                            ),
                            const Divider(height: 28),
                            Text(
                              'Manual Phase Transition',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              key: ValueKey<String>(
                                'phase-$phaseSelection',
                              ),
                              initialValue: phaseSelection,
                              decoration: const InputDecoration(
                                labelText: 'Target Phase',
                              ),
                              items: actorPhases
                                  .map(
                                    (phase) => DropdownMenuItem<int>(
                                      value: phase.id,
                                      child:
                                          Text('${phase.name} (#${phase.id})'),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _manualPhaseId = value;
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            FilledButton.icon(
                              onPressed: phaseSelection == null
                                  ? null
                                  : () {
                                      signal.transitionSelectedActorPhase(
                                        phaseSelection,
                                      );
                                    },
                              icon: const Icon(Icons.swap_horiz_rounded),
                              label: const Text('Transition Phase'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _TimelineTrack extends StatelessWidget {
  final int nowMs;
  final List<SimulationTrackMarker> markers;
  final Color Function(SimulatedEventType type) colorForType;

  const _TimelineTrack({
    required this.nowMs,
    required this.markers,
    required this.colorForType,
  });

  @override
  Widget build(BuildContext context) {
    const lookBehindMs = 10000;
    const lookAheadMs = 30000;

    final startMs = nowMs - lookBehindMs;
    final endMs = nowMs + lookAheadMs;
    final span = (endMs - startMs).toDouble();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final nowX = ((nowMs - startMs) / span) * width;

        final visibleMarkers = markers
            .where(
              (marker) =>
                  marker.timestampMs >= startMs && marker.timestampMs <= endMs,
            )
            .toList();

        return Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            for(final marker in visibleMarkers)
              Positioned(
                left: (((marker.timestampMs - startMs) / span) * width)
                    .clamp(0, width - 2),
                top: marker.isPast ? 44 : 8,
                child: Tooltip(
                  message: marker.label,
                  child: Container(
                    width: 2,
                    height: 46,
                    color: colorForType(marker.type)
                        .withValues(alpha: marker.isPast ? 0.7 : 1),
                  ),
                ),
              ),
            Positioned(
              left: nowX.clamp(0, width - 2),
              top: 0,
              bottom: 0,
              child: Container(
                width: 2,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            Positioned(
              left: 8,
              bottom: 6,
              child: Text(
                '-10s',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Positioned(
              left: (nowX - 16).clamp(0, width - 40),
              bottom: 6,
              child: Text(
                'Now',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Positioned(
              right: 8,
              bottom: 6,
              child: Text(
                '+30s',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        );
      },
    );
  }
}
