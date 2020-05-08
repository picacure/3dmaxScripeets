fn BakeDiffuseAndLighting obj size =
(
	--Clear all render elements 
	obj.iNodeBakeProperties.removeAllBakeElements() 
	--Preparing the Bake Elements:
	be1 = diffusemap() --instance of the bake element class
	be1.outputSzX = be1.outputSzY = size --set the size of the baked map
	--specifythe full file path, name and type:
	be1.fileType = (getDir #image+"\\"+obj.name+"_diffuse.tga")
	be1.fileName = filenameFromPath be1.fileType
	be1.filterOn = true --enable filtering
	be1.shadowsOn = false --disable shadows
	be1.lightingOn = false --disable lighting
	be1.enabled = true --enable baking
	be2 = LightingMap() -- instance of the bake element class
	be2.outputSzX =be2.outputSzY = size --set the size of the baked map
	--specifythe full file path, name and type:
	be2.fileType = (getDir #image+"\\"+obj.name+"_lighting.tga")
	be2.fileName = filenameFromPath be2.fileType
	be2.filterOn = true --enable filtering
	be2.shadowsOn =true --enable shadows
	be2.enabled = true --enable baking
	--Preparing theobjectfor baking:
	obj.INodeBakeProperties.addBakeElement be1 --add first element
	obj.INodeBakeProperties.addBakeElement be2 --add second element
	obj.INodeBakeProperties.bakeEnabled = true --enabling baking
	obj.INodeBakeProperties.bakeChannel = 1 --channel to bake
	obj.INodeBakeProperties.nDilations = 1 --expand the texturea bit
	select obj --we are baking the selection, so we select the object
	--Call the renderer to bake both elements:
	render rendertype:#bakeSelected vfb:off progressBar:true outputSize:[size,size]
	theComp = CompositeTextureMap() --create a composite map
	theComp.add() --add a second layer
	theComp.blendMode = #(0,5) --set second layer to Multiply 
	--Create two maps, one with the diffuse, one with the lighting map
	theMap1 =bitmaptexture filename:be1.fileType
	theMap2=bitmaptexture filename:be2.fileType
	theComp.mapList = #(theMap1,theMap2) --composite the two maps
	theComp.opacity = #(100,70) --set the lighting map to 70% opacity
	--Create a standard self-illum material using the Composite map
	bakedMat = standard diffusemap:theComp selfIllumAmount:100
	--Assign a Shell Material to the object,
	--keep the old material as original material,
	--set the new bakedMat as the baked material:
	obj.material = Shell_Material originalMaterial:obj.material\
	bakedMaterial:bakedMat viewportMtlIndex:1 renderMtlIndex:1
	--Show the textures of the baked material in the viewport
	showTextureMap obj.material obj.material.bakedMaterial true
)--end fn



resetMaxFile #noprompt--reset the scene to start from scratch
--Create a shadow casting white Omni light
theLight = omniLight pos:[0,-60,100] rgb:white
theLight.baseobject.castshadows = true
--Create a mapped sphere object above the ground plane
theObject = Sphere segs:32 mapcoords:true pos:[0,0,25]
--Create a Cellular map and assign via Standard material to object
theMap = cellular cellColor:blue divColor1:red divColor2:yellow size:15
theObject.material = standard diffusemap:theMap
--Call the Bake function with the object and the desired size
BakeDiffuseAndLighting theObject 256
--Create a mappedplaneobjecton theground plane
theObject = Plane width:200 length:200 mapcoords:true
--Create a checker map and set the tiling to 4x4, then assign to object
theMap = checker Color1:green Color2:orange
theMap.coordinates.uTiling = theMap.coordinates.vTiling = 4
theObject.material = standard diffusemap:theMap
--Call the Bake function with the object and the desired size
BakeDiffuseAndLighting theObject 256
--Delete the light from the scene and deselect everything
delete theLight


max select none