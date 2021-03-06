# Find connected features in utility networks

Find all features connected to a set of starting points in a utility network.

![](screenshot.png)

## Use case

This is useful to visualize and validate the network topology of a utility network for quality assurance.

## How to use the sample

To add a starting point, select 'Add starting location(s)' and tap on one or more features. To add a barrier, select 'Add barrier(s)' and tap on one or more features. Depending on the type of feature, you may be prompted to select a terminal or the distance from the tapped location will be computed. Click 'Trace' to highlight all features connected to the specified starting locations and not positioned beyond the barriers. Click 'Reset' to clear parameters and start over.

## How it works

1. Create a `MapView` and connect to its `mouseClicked` signal.
2. Create and load a `Map` that contains `FeatureLayer`(s) that are part of a utility network.
3. Create and load a `UtilityNetwork` with the same feature service URL and map.
4. Add a `GraphicsOverlay` with symbology that distinguishes starting points from barriers.
5. Identify features on the map and add a `Graphic` that represents its purpose (starting point or barrier) at the location of each identified feature.
6. Determine the type of the identified feature using `UtilityNetwork.definition.networkSource` passing its table name.
7. If a junction, display a terminal picker when more than one terminal is found and create a `UtilityElement` with the selected terminal or the single terminal if there is only one.
8. If an edge, create a `UtilityElement` from the identified feature and compute its `FractionAlongLine` using `GeometryEngine.fractionAlong`.
9. Run a `UtilityNetwork.trace` with the specified parameters.
10. Create two list of ObjectId's from `UtilityElementTraceResult.Elements` separated by their `NetworkSource.Name`.
11. Create two `QueryParameters` and assign each a list of ObjectId's.
12. For every feature layer in this map with elements, select features by passing in their respective query parameters.

## Relevant API

* UtilityNetwork
* UtilityTraceParameters
* UtilityTraceResult
* UtilityElementTraceResult
* UtilityNetworkDefinition
* UtilityNetworkSource
* UtilityAssetType
* UtilityTerminal
* GeometryEngine.fractionAlong

## About the data

The sample uses a dark vector basemap. It includes a subset of feature layers from a feature service that contains the same utility network used to run the connected trace.

## Tags

connected trace, network analysis, utility network
