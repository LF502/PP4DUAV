macroScript GirdsDEM category: "GirdsDEM" tooltip:"Girds DEM" Icon:#("NURBSSurface",1)
(

rollout DEMRollout "Girds DEM" width:162 height:225
(
	button start "Start" pos:[190,10] width:40 height:50
	pickButton PickGround "Pick\nGround" pos:[5,10] width:45 height:50
	label info "Pick a ground before pressing start" pos:[60,10] width:125 height:55
	
	groupBox groupbox0 "Girds on X" pos:[5,65] width:110 height:95
	label info0 "Min X" pos:[20,85] width:30 height:20
	editText input0 "" pos:[50,83] width:50 height:20
	label info1 "Max X" pos:[20,110] width:30 height:20
	editText input1 "" pos:[50,108] width:50 height:20
	label info2 "Step" pos:[25,135] width:25 height:20
	editText input2 "" pos:[50,133] width:50 height:20
	
	groupBox groupbox1 "Girds on Y" pos:[120,65] width:110 height:95
	label info4 "Min Y" pos:[135,85] width:30 height:20
	editText input4 "" pos:[165,83] width:50 height:20
	label info5 "Max Y" pos:[135,110] width:30 height:20
	editText input5 "" pos:[165,108] width:50 height:20
	label info6 "Step" pos:[140,135] width:25 height:20
	editText input6 "" pos:[165,133] width:50 height:20
	
	groupBox groupbox2 "Advanced Option" pos:[5,170] width:225 height:45
	label info7 "Sampling" pos:[15,190] width:50 height:20
	editText input7 "" pos:[65,188] width:40 height:20
	label info8 "From Z" pos:[130,190] width:35 height:20
	editText input8 "" pos:[165,188] width:50 height:20


	on DEMRollout open do
	(
		global minx = 0
		global maxx = 0
		global stepx = 1
		global miny = 0
		global maxy = 0
		global stepy = 1
		global samp = 0
		global z = 9999
		global ground
	)
	
	on start pressed  do
	(
		
		try(
			info.text = "Generating DEM of " + ground.name
			try(
				filename= getSaveFileName caption:"Save to..." initialDir:getSavePath filename:"DEM.csv"
				file = createFile filename
				x = minx
				y = miny
				xs = #()
				ys = #()
				while (x <= maxx) do (
					append xs x
					x += stepx
				)
				while (y <= maxy) do (
					append ys y
					y += stepy
				)
				if samp == 0 then(
					for x in xs do (
						for y in ys do (
							try(
							node = (intersectRay ground (ray [x,y,z] [0,0,-1]))
							format "%,%,%\n" x y (floor (1000 * node.pos.z) / 1000) to:file
							)
							catch ()
						)
					)
				) else (
					for x in xs do (
						for y in ys do (
							nodes = #()
							for i = 0 to (stepx / samp) do (
								for j = 0 to (stepy / samp) do (
									try(
										node = (intersectRay ground (ray [(x+i*samp),(y+j*samp),z] [0,0,-1]))
										append nodes node.pos.z
									)
									catch()
								)
							)
							if nodes.count do(format "%,%,%\n" x y (amax nodes) to:file)
						)
					)
				)
				
				info.text = "DEM of " + ground.name + " generated"
				close file
				edit filename
			)
			catch(
				info.text = "Failed to generate"
				close file
			)
		)
		catch(
			info.text = "No ground picked!"
		)
	)
	
	on PickGround picked obj do
	(
		ground = obj
		info.text = "Ground: " + obj.name
	)
	
	on input0 entered text do
	(
	minx = text as float
	)
	
	on input1 entered text do
	(
	maxx = text as float
	)
	
	on input2 entered text do
	(
	stepx = text as float
	)
	
	on input4 entered text do
	(
	miny = text as float
	)
	
	on input5 entered text do
	(
	maxy = text as float
	)
	
	on input6 entered text do
	(
	stepy = text as float
	)
	
	on input7 entered text do
	(
	samp = text as float
	)
	
	on input8 entered text do
	(
	z = text as float
	)
	
)


------------------------------
--- addRollout --------------
------------------------------
nrf = NewRolloutFloater "Girds DEM" 250 245
	addRollout DEMRollout nrf

)
