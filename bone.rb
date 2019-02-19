def r_f(_type,_up,_sl)
	_i=_type.read(_up).unpack("V")
	return gl_v(_i.to_s,_sl).to_i
end
def gl_v(_o,_type)
	if _type == 0
		return _o.gsub("[","").gsub("]","")
	elsif _type == 16
		return _o.gsub("[","").gsub("]","").to_i.to_s(16)
	end
end
def boneEntryread(_o,_off)
	_o.seek(_off)
	for _k in 0..999
		type=gl_v(_o.read(1).unpack("C").to_s,0).to_i
		#puts type
		BoneType(type)
		boole=gl_v(_o.read(1).unpack("C").to_s,0).to_i
		if boole == 0
			puts "无父级"
		elsif boole == 1
			puts "有父级"
		end
		#field
		for _l in 1..4
			puts gl_v(_o.read(1).unpack("C").to_s,0).to_i
		end
		_o.read(2)
		_name_offse=r_f(_o,4,0).to_i
		#puts _name_offse
		#print 
		$bone_name=readstr(_o,_name_offse)
		print $bone_name,"\n"
		if /End/ =~ $bone_name.to_s
			break
		end
	end
end
def readstr(_f,_off)
	_tmp_o=[0,0]
	_tmp_save_pos=_f.pos.to_i#存储当前位置
	_f.seek(_off)#设置到名字的offset
	for _g in 0..99
		_tmp_o[_g]=_f.read(1).to_s
		if _tmp_o[_g] == "\x00"
			break
		end
	end
	_tmp_o=_tmp_o.join("")
	_f.seek(_tmp_save_pos)
	return _tmp_o
end
def BoneType(_p)
	case _p.to_i
	when 0
		puts "Rotation"
	when 1
		puts "Type1"
	when 2
		puts "Position"
	when 3
		puts "Type3"
	when 4
		puts "Type4"
	when 5
		puts "Type5"
	when 6
		puts "Type6"
	else
	end
end
def vex3(_f,_lx)
	_x=ff_gl(_f.read(4).unpack(_lx).to_s).to_f.round(3)
	_y=ff_gl(_f.read(4).unpack(_lx).to_s).to_f.round(3)
	_z=ff_gl(_f.read(4).unpack(_lx).to_s).to_f.round(3)
	print _x,",",_y,",",_z,",","\n"
end
def ff_gl(_o)
	return _o.gsub("[","").gsub("]","").to_f
end
def readstr_cs(_f,_off,_cs)
	_f.seek(_off)
	for _s in 1.._cs
		puts gl_v(_f.read(4).to_s,0).to_s
	end
end
file=File.open("bone_data.bin","rb")
puts r_f(file,4,16)#head
i=r_f(file,4,0).to_i#角色计数
puts i
p=r_f(file,4,0).to_i#boneoffset
puts p.to_s(16)
o=r_f(file,4,0).to_i#nameoffset
puts o.to_s(16)

#角色列表
puts "-------------------"
file.seek(o)
$chara_name=[0,0]
for o in 0..(i-1)
	name_set=o
	chara_seek=r_f(file,4,0).to_i
	#puts chara_seek.to_s(16)
	chara_pos=file.pos.to_i#保存当前pos
	file.seek(chara_seek)
	$chara_name[name_set]=gl_v(file.read(4).to_s,0).to_s
	file.seek(chara_pos)#回到pos
end
puts "-------------------"
puts "chara_name_table"
print $chara_name,"\n"
puts "-------------------"

#bonesOffset
puts "chara_bone_info_offset"
file.seek(p)
$bone_offset_table=[0,0]
for o in 0..(i-1)
	tmp_bone_set=i-o-1
	tmp_bone_pos=file.pos.to_i
	#file.seek()
	$bone_offset_table[tmp_bone_set]=r_f(file,4,0).to_i
	#file.seek(tmp_bone_pos)#回到pos
end
print $bone_offset_table,"\n"
puts "-------------------"
file.seek($bone_offset_table[0])
bonesOffset=r_f(file,4,0)
positionCount=r_f(file,4,0)
positionsOffset=r_f(file,4,0)
field02Offset=r_f(file,4,0)
boneName1Count=r_f(file,4,0)
boneNames1Offset=r_f(file,4,0)
boneName2Count=r_f(file,4,0)
boneNames2Offset=r_f(file,4,0)
parentIndicesOffset=r_f(file,4,0)
#puts positionCount
puts "-------------------"
boneEntryread(file,bonesOffset)
puts "-------------------"
#positionsOffset
file.seek(positionsOffset)
puts positionsOffset.to_s(16)
for d in 1..positionCount
	vex3(file,"F")
end
#field02Offset
puts "-------------------"
file.seek(field02Offset)
field02=r_f(file,4,0)
puts field02
puts "-------------------"
#boneNames1Offset
#puts file.pos.to_s(16)
#readstr_cs(file,boneNames1Offset,boneName1Count)
puts parentIndicesOffset.to_s(16)
puts "-------------------"
puts "pos=#{file.pos.to_s(16)}"
