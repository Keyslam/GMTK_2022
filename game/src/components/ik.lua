local Ik = ECS.component("ik", function(e, root, rootConnection, hip, hipConnection, knee)
	e.root = root
	e.rootConnection = rootConnection
	e.hip = hip
	e.hipConnection = hipConnection
	e.knee = knee
end)