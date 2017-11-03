cmake_minimum_required ( VERSION 3.1 )
#########################################################################################
#
#   Library: Entitas
#
#########################################################################################
project ( entitas VERSION 0.1.0 )

list (APPEND ENTITAS .lib/entitas/src/entitas.vala)
list (APPEND ENTITAS .lib/entitas/src/Group.vala)
list (APPEND ENTITAS .lib/entitas/src/Matcher.vala)
list (APPEND ENTITAS .lib/entitas/src/World.vala)
list (APPEND ENTITAS .lib/entitas/src/events/ComponentReplaced.vala)
list (APPEND ENTITAS .lib/entitas/src/events/EntityChanged.vala)
list (APPEND ENTITAS .lib/entitas/src/events/EntityReleased.vala)
list (APPEND ENTITAS .lib/entitas/src/events/GroupChanged.vala)
list (APPEND ENTITAS .lib/entitas/src/events/GroupsChanged.vala)
list (APPEND ENTITAS .lib/entitas/src/events/GroupUpdated.vala)
list (APPEND ENTITAS .lib/entitas/src/events/WorldChanged.vala)

set (VALA_SOURCES "${VALA_SOURCES};${ENTITAS}" PARENT_SCOPE)

