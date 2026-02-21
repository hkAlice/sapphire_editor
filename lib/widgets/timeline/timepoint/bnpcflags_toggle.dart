import 'package:flutter/material.dart';
import 'package:sapphire_editor/models/timeline/timepoint/types/bnpcflags_point_model.dart';
import 'package:sapphire_editor/widgets/generic_item_picker_widget.dart';
import 'package:sapphire_editor/utils/text_utils.dart';

enum FlagState { unchanged, set, clear }

enum InvincibilityType { none, refill, stayAlive, ignoreDamage }

class TriStateFlagWidget extends StatelessWidget {
  final String label;
  final FlagState state;
  final VoidCallback onPressed;

  const TriStateFlagWidget(
      {super.key,
      required this.label,
      required this.state,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    String stateStr = state == FlagState.unchanged
        ? "Unchanged"
        : state == FlagState.set
            ? "Set"
            : "Clear";
    Color color = state == FlagState.unchanged
        ? Colors.grey
        : state == FlagState.set
            ? Colors.greenAccent
            : Colors.redAccent;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
            Container(
              width: 70,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                  color: color.withAlpha(50),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: color.withAlpha(100))),
              child:
                  Text(stateStr, style: TextStyle(color: color, fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }
}

class BNpcFlagsToggle extends StatelessWidget {
  final int flags;
  final int? flagsMask;
  final int? invulnType;
  final Function(int, int?, int?) onUpdate;
  final bool isDense;

  const BNpcFlagsToggle(
      {super.key,
      required this.flags,
      this.flagsMask,
      this.invulnType,
      required this.onUpdate,
      this.isDense = false});

  FlagState _getFlagState(int flagBit) {
    int mask = flagsMask ?? 0xFFFFFFFF;

    if((mask & flagBit) == 0) return FlagState.unchanged;
    if((flags & flagBit) != 0) return FlagState.set;
    return FlagState.clear;
  }

  void _cycleFlag(int flagBit) {
    FlagState current = _getFlagState(flagBit);
    FlagState next;
    if(current == FlagState.unchanged)
      next = FlagState.set;
    else if(current == FlagState.set)
      next = FlagState.clear;
    else
      next = FlagState.unchanged;

    int mask = flagsMask ?? 0xFFFFFFFF;
    int newFlags = flags;

    if(next == FlagState.unchanged) {
      mask &= ~flagBit;
      newFlags &= ~flagBit;
    } else if(next == FlagState.set) {
      mask |= flagBit;
      newFlags |= flagBit;
    } else {
      mask |= flagBit;
      newFlags &= ~flagBit;
    }

    onUpdate(newFlags, mask, invulnType);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          isDense
              ? Container()
              : Expanded(
                  child: Center(
                      child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Flags",
                        style: Theme.of(context).textTheme.labelSmall),
                    Text(flags.toRadixString(2).padLeft(12, "0"),
                        style: Theme.of(context).textTheme.displaySmall),
                    if(flagsMask != null) ...[
                      const SizedBox(height: 8),
                      Text("Mask",
                          style: Theme.of(context).textTheme.labelSmall),
                      Text(flagsMask!.toRadixString(2).padLeft(12, "0"),
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: Colors.grey)),
                    ]
                  ],
                ))),
          SizedBox(
            width: 170,
            child: Column(
              children: [
                TriStateFlagWidget(
                  label: "Immobile",
                  state: _getFlagState(BNpcFlags.immobile),
                  onPressed: () => _cycleFlag(BNpcFlags.immobile),
                ),
                TriStateFlagWidget(
                  label: "DisableRot",
                  state: _getFlagState(BNpcFlags.turningDisabled),
                  onPressed: () => _cycleFlag(BNpcFlags.turningDisabled),
                ),
                TriStateFlagWidget(
                  label: "Invuln",
                  state: _getFlagState(BNpcFlags.invincible),
                  onPressed: () => _cycleFlag(BNpcFlags.invincible),
                ),
                TriStateFlagWidget(
                  label: "InvulnRefill",
                  state: _getFlagState(BNpcFlags.invincibleRefill),
                  onPressed: () => _cycleFlag(BNpcFlags.invincibleRefill),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 170,
            child: Column(
              children: [
                TriStateFlagWidget(
                  label: "NoDeaggro",
                  state: _getFlagState(BNpcFlags.noDeaggro),
                  onPressed: () => _cycleFlag(BNpcFlags.noDeaggro),
                ),
                TriStateFlagWidget(
                  label: "Untargetable",
                  state: _getFlagState(BNpcFlags.untargetable),
                  onPressed: () => _cycleFlag(BNpcFlags.untargetable),
                ),
                TriStateFlagWidget(
                  label: "NoAutoAttack",
                  state: _getFlagState(BNpcFlags.autoAttackDisabled),
                  onPressed: () => _cycleFlag(BNpcFlags.autoAttackDisabled),
                ),
                TriStateFlagWidget(
                  label: "Invisible",
                  state: _getFlagState(BNpcFlags.invisible),
                  onPressed: () => _cycleFlag(BNpcFlags.invisible),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 170,
            child: Column(
              children: [
                TriStateFlagWidget(
                  label: "NoRoam",
                  state: _getFlagState(BNpcFlags.noRoam),
                  onPressed: () => _cycleFlag(BNpcFlags.noRoam),
                ),
                TriStateFlagWidget(
                  label: "Unused1",
                  state: _getFlagState(BNpcFlags.unused1),
                  onPressed: () => _cycleFlag(BNpcFlags.unused1),
                ),
                TriStateFlagWidget(
                  label: "Unused2",
                  state: _getFlagState(BNpcFlags.unused2),
                  onPressed: () => _cycleFlag(BNpcFlags.unused2),
                ),
                TriStateFlagWidget(
                  label: "Unused3",
                  state: _getFlagState(BNpcFlags.unused3),
                  onPressed: () => _cycleFlag(BNpcFlags.unused3),
                ),
              ],
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Row(
          children: [
            SizedBox(
              width: 250,
              child: GenericItemPickerWidget<InvincibilityType>(
                label: "Invincibility Type",
                items: InvincibilityType.values,
                initialValue: InvincibilityType.values[invulnType ?? 0],
                propertyBuilder: (value) => treatEnumName(value),
                onChanged: (newValue) {
                  onUpdate(flags, flagsMask, newValue.index);
                },
              ),
            )
          ],
        )
      ],
    );
  }
}
