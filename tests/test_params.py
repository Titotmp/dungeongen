"""Tests for GenerationParams (layout/params.py)."""

from dungeongen.layout.params import (
    CIRCLE_RADII,
    ROOM_COUNTS,
    ROOM_TEMPLATES,
    DungeonSize,
    GenerationParams,
)


def test_room_count_range_uses_size_unless_overridden():
    assert GenerationParams(size=DungeonSize.TINY).get_room_count_range() == ROOM_COUNTS[DungeonSize.TINY]
    assert GenerationParams(room_count=(3, 7)).get_room_count_range() == (3, 7)


def test_room_templates_grow_with_size_bias():
    cozy = GenerationParams(room_size_bias=-0.8).get_room_templates()
    small = GenerationParams(room_size_bias=-0.2).get_room_templates()
    balanced = GenerationParams(room_size_bias=0.2).get_room_templates()
    grand = GenerationParams(room_size_bias=0.9).get_room_templates()

    assert cozy == ROOM_TEMPLATES['cozy']
    assert small == ROOM_TEMPLATES['small']
    assert len(balanced) == len(ROOM_TEMPLATES['small']) + len(ROOM_TEMPLATES['medium'])
    # Very grand doubles the weight of large rooms
    assert len(grand) == (
        len(ROOM_TEMPLATES['small']) + len(ROOM_TEMPLATES['medium']) + 2 * len(ROOM_TEMPLATES['large'])
    )


def test_circle_radii_by_bias():
    assert GenerationParams(room_size_bias=-0.8).get_circle_radii() == CIRCLE_RADII['cozy']
    assert GenerationParams(room_size_bias=0.0).get_circle_radii() == CIRCLE_RADII['small'] + CIRCLE_RADII['medium']
    assert GenerationParams(room_size_bias=0.5).get_circle_radii() == CIRCLE_RADII['medium'] + CIRCLE_RADII['large']
