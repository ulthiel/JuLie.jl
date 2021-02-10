@testset "Imprimitive complex reflection groups" begin

	#Magma code
	# T := [[ 2, 1, 2 ],[ 3, 1, 2 ],[ 3, 3, 2 ],[ 4, 1, 2 ],[ 4, 2, 2 ],[ 4, 4, 2 ],[ 5, 1, 2 ],[ 5, 5, 2 ],[ 2, 1, 3 ],[ 2, 2, 3 ],[ 3, 1, 3 ],[ 3, 3, 3 ],[ 4, 1, 3 ],[ 4, 2, 3 ],[ 4, 4, 3 ],[ 5, 1, 3 ],[ 5, 5, 3 ],[ 2, 1, 4 ],[ 2, 2, 4 ],[ 3, 1, 4 ],[ 3, 3, 4 ],[ 4, 1, 4 ],[ 4, 2, 4 ],[ 4, 4, 4 ],[ 5, 1, 4 ],[ 5, 5, 4 ],[ 2, 1, 5 ],[ 2, 2, 5 ],[ 3, 1, 5 ],[ 3, 3, 5 ],[ 4, 1, 5 ],[ 4, 2, 5 ],[ 4, 4, 5 ],[ 5, 1, 5 ],[ 5, 5, 5 ]];
	# for t in T do; W:=ShephardTodd(t[1],t[2],t[3]); o := #W; Sprint("@test order(ImprimitiveComplexReflectionGroup(")*Sprint(t[1])*","*Sprint(t[2])*","*Sprint(t[3])*")) == "*Sprint(o); end for;

	#order
	@test order(ImprimitiveComplexReflectionGroup(2,1,2)) == 8
	@test order(ImprimitiveComplexReflectionGroup(3,1,2)) == 18
	@test order(ImprimitiveComplexReflectionGroup(3,3,2)) == 6
	@test order(ImprimitiveComplexReflectionGroup(4,1,2)) == 32
	@test order(ImprimitiveComplexReflectionGroup(4,2,2)) == 16
	@test order(ImprimitiveComplexReflectionGroup(4,4,2)) == 8
	@test order(ImprimitiveComplexReflectionGroup(5,1,2)) == 50
	@test order(ImprimitiveComplexReflectionGroup(5,5,2)) == 10
	@test order(ImprimitiveComplexReflectionGroup(2,1,3)) == 48
	@test order(ImprimitiveComplexReflectionGroup(2,2,3)) == 24
	@test order(ImprimitiveComplexReflectionGroup(3,1,3)) == 162
	@test order(ImprimitiveComplexReflectionGroup(3,3,3)) == 54
	@test order(ImprimitiveComplexReflectionGroup(4,1,3)) == 384
	@test order(ImprimitiveComplexReflectionGroup(4,2,3)) == 192
	@test order(ImprimitiveComplexReflectionGroup(4,4,3)) == 96
	@test order(ImprimitiveComplexReflectionGroup(5,1,3)) == 750
	@test order(ImprimitiveComplexReflectionGroup(5,5,3)) == 150
	@test order(ImprimitiveComplexReflectionGroup(2,1,4)) == 384
	@test order(ImprimitiveComplexReflectionGroup(2,2,4)) == 192
	@test order(ImprimitiveComplexReflectionGroup(3,1,4)) == 1944
	@test order(ImprimitiveComplexReflectionGroup(3,3,4)) == 648
	@test order(ImprimitiveComplexReflectionGroup(4,1,4)) == 6144
	@test order(ImprimitiveComplexReflectionGroup(4,2,4)) == 3072
	@test order(ImprimitiveComplexReflectionGroup(4,4,4)) == 1536
	@test order(ImprimitiveComplexReflectionGroup(5,1,4)) == 15000
	@test order(ImprimitiveComplexReflectionGroup(5,5,4)) == 3000
	@test order(ImprimitiveComplexReflectionGroup(2,1,5)) == 3840
	@test order(ImprimitiveComplexReflectionGroup(2,2,5)) == 1920
	@test order(ImprimitiveComplexReflectionGroup(3,1,5)) == 29160
	@test order(ImprimitiveComplexReflectionGroup(3,3,5)) == 9720
	@test order(ImprimitiveComplexReflectionGroup(4,1,5)) == 122880
	@test order(ImprimitiveComplexReflectionGroup(4,2,5)) == 61440
	@test order(ImprimitiveComplexReflectionGroup(4,4,5)) == 30720
	@test order(ImprimitiveComplexReflectionGroup(5,1,5)) == 375000
	@test order(ImprimitiveComplexReflectionGroup(5,5,5)) == 75000

	#degrees
	@test degrees(ImprimitiveComplexReflectionGroup(2,1,2)) == [ 2, 4 ]
	@test degrees(ImprimitiveComplexReflectionGroup(3,1,2)) == [ 3, 6 ]
	@test degrees(ImprimitiveComplexReflectionGroup(3,3,2)) == [ 2, 3 ]
	@test degrees(ImprimitiveComplexReflectionGroup(4,1,2)) == [ 4, 8 ]
	@test degrees(ImprimitiveComplexReflectionGroup(4,2,2)) == [ 4, 4 ]
	@test degrees(ImprimitiveComplexReflectionGroup(4,4,2)) == [ 2, 4 ]
	@test degrees(ImprimitiveComplexReflectionGroup(5,1,2)) == [ 5, 10 ]
	@test degrees(ImprimitiveComplexReflectionGroup(5,5,2)) == [ 2, 5 ]
	@test degrees(ImprimitiveComplexReflectionGroup(2,1,3)) == [ 2, 4, 6 ]
	@test degrees(ImprimitiveComplexReflectionGroup(2,2,3)) == [ 2, 3, 4 ]
	@test degrees(ImprimitiveComplexReflectionGroup(3,1,3)) == [ 3, 6, 9 ]
	@test degrees(ImprimitiveComplexReflectionGroup(3,3,3)) == [ 3, 3, 6 ]
	@test degrees(ImprimitiveComplexReflectionGroup(4,1,3)) == [ 4, 8, 12 ]
	@test degrees(ImprimitiveComplexReflectionGroup(4,2,3)) == [ 4, 6, 8 ]
	@test degrees(ImprimitiveComplexReflectionGroup(4,4,3)) == [ 3, 4, 8 ]
	@test degrees(ImprimitiveComplexReflectionGroup(5,1,3)) == [ 5, 10, 15 ]
	@test degrees(ImprimitiveComplexReflectionGroup(5,5,3)) == [ 3, 5, 10 ]
	@test degrees(ImprimitiveComplexReflectionGroup(2,1,4)) == [ 2, 4, 6, 8 ]
	@test degrees(ImprimitiveComplexReflectionGroup(2,2,4)) == [ 2, 4, 4, 6 ]
	@test degrees(ImprimitiveComplexReflectionGroup(3,1,4)) == [ 3, 6, 9, 12 ]
	@test degrees(ImprimitiveComplexReflectionGroup(3,3,4)) == [ 3, 4, 6, 9 ]
	@test degrees(ImprimitiveComplexReflectionGroup(4,1,4)) == [ 4, 8, 12, 16 ]
	@test degrees(ImprimitiveComplexReflectionGroup(4,2,4)) == [ 4, 8, 8, 12 ]
	@test degrees(ImprimitiveComplexReflectionGroup(4,4,4)) == [ 4, 4, 8, 12 ]
	@test degrees(ImprimitiveComplexReflectionGroup(5,1,4)) == [ 5, 10, 15, 20 ]
	@test degrees(ImprimitiveComplexReflectionGroup(5,5,4)) == [ 4, 5, 10, 15 ]
	@test degrees(ImprimitiveComplexReflectionGroup(2,1,5)) == [ 2, 4, 6, 8, 10 ]
	@test degrees(ImprimitiveComplexReflectionGroup(2,2,5)) == [ 2, 4, 5, 6, 8 ]
	@test degrees(ImprimitiveComplexReflectionGroup(3,1,5)) == [ 3, 6, 9, 12, 15 ]
	@test degrees(ImprimitiveComplexReflectionGroup(3,3,5)) == [ 3, 5, 6, 9, 12 ]

	#num_reflections
	@test num_reflections(ImprimitiveComplexReflectionGroup(2,1,2)) == 4
	@test num_reflections(ImprimitiveComplexReflectionGroup(3,1,2)) == 7
	@test num_reflections(ImprimitiveComplexReflectionGroup(3,3,2)) == 3
	@test num_reflections(ImprimitiveComplexReflectionGroup(4,1,2)) == 10
	@test num_reflections(ImprimitiveComplexReflectionGroup(4,2,2)) == 6
	@test num_reflections(ImprimitiveComplexReflectionGroup(4,4,2)) == 4
	@test num_reflections(ImprimitiveComplexReflectionGroup(5,1,2)) == 13
	@test num_reflections(ImprimitiveComplexReflectionGroup(5,5,2)) == 5
	@test num_reflections(ImprimitiveComplexReflectionGroup(2,1,3)) == 9
	@test num_reflections(ImprimitiveComplexReflectionGroup(2,2,3)) == 6
	@test num_reflections(ImprimitiveComplexReflectionGroup(3,1,3)) == 15
	@test num_reflections(ImprimitiveComplexReflectionGroup(3,3,3)) == 9
	@test num_reflections(ImprimitiveComplexReflectionGroup(4,1,3)) == 21
	@test num_reflections(ImprimitiveComplexReflectionGroup(4,2,3)) == 15
	@test num_reflections(ImprimitiveComplexReflectionGroup(4,4,3)) == 12
	@test num_reflections(ImprimitiveComplexReflectionGroup(5,1,3)) == 27
	@test num_reflections(ImprimitiveComplexReflectionGroup(5,5,3)) == 15
	@test num_reflections(ImprimitiveComplexReflectionGroup(2,1,4)) == 16
	@test num_reflections(ImprimitiveComplexReflectionGroup(2,2,4)) == 12
	@test num_reflections(ImprimitiveComplexReflectionGroup(3,1,4)) == 26
	@test num_reflections(ImprimitiveComplexReflectionGroup(3,3,4)) == 18
	@test num_reflections(ImprimitiveComplexReflectionGroup(4,1,4)) == 36
	@test num_reflections(ImprimitiveComplexReflectionGroup(4,2,4)) == 28
	@test num_reflections(ImprimitiveComplexReflectionGroup(4,4,4)) == 24
	@test num_reflections(ImprimitiveComplexReflectionGroup(5,1,4)) == 46
	@test num_reflections(ImprimitiveComplexReflectionGroup(5,5,4)) == 30
	@test num_reflections(ImprimitiveComplexReflectionGroup(2,1,5)) == 25
	@test num_reflections(ImprimitiveComplexReflectionGroup(2,2,5)) == 20
	@test num_reflections(ImprimitiveComplexReflectionGroup(3,1,5)) == 40
	@test num_reflections(ImprimitiveComplexReflectionGroup(3,3,5)) == 30
	@test num_reflections(ImprimitiveComplexReflectionGroup(4,1,5)) == 55
	@test num_reflections(ImprimitiveComplexReflectionGroup(4,2,5)) == 45
	@test num_reflections(ImprimitiveComplexReflectionGroup(4,4,5)) == 40
	@test num_reflections(ImprimitiveComplexReflectionGroup(5,1,5)) == 70
	@test num_reflections(ImprimitiveComplexReflectionGroup(5,5,5)) == 50

	#num_classes_reflections
	@test num_classes_reflections(ImprimitiveComplexReflectionGroup(2,1,2)) == 2
	@test num_classes_reflections(ImprimitiveComplexReflectionGroup(3,1,2)) == 3
	@test num_classes_reflections(ImprimitiveComplexReflectionGroup(3,3,2)) == 1
	@test num_classes_reflections(ImprimitiveComplexReflectionGroup(4,1,2)) == 4
	@test num_classes_reflections(ImprimitiveComplexReflectionGroup(4,2,2)) == 3
	@test num_classes_reflections(ImprimitiveComplexReflectionGroup(4,4,2)) == 2
	@test num_classes_reflections(ImprimitiveComplexReflectionGroup(5,1,2)) == 5
	@test num_classes_reflections(ImprimitiveComplexReflectionGroup(5,5,2)) == 1
	@test num_classes_reflections(ImprimitiveComplexReflectionGroup(2,1,3)) == 2
	@test num_classes_reflections(ImprimitiveComplexReflectionGroup(2,2,3)) == 1
	@test num_classes_reflections(ImprimitiveComplexReflectionGroup(3,1,3)) == 3
	@test num_classes_reflections(ImprimitiveComplexReflectionGroup(3,3,3)) == 1
	@test num_classes_reflections(ImprimitiveComplexReflectionGroup(4,1,3)) == 4
	@test num_classes_reflections(ImprimitiveComplexReflectionGroup(4,2,3)) == 2
	@test num_classes_reflections(ImprimitiveComplexReflectionGroup(4,4,3)) == 1
	@test num_classes_reflections(ImprimitiveComplexReflectionGroup(5,1,3)) == 5
	@test num_classes_reflections(ImprimitiveComplexReflectionGroup(5,5,3)) == 1
	@test num_classes_reflections(ImprimitiveComplexReflectionGroup(2,1,4)) == 2
	@test num_classes_reflections(ImprimitiveComplexReflectionGroup(2,2,4)) == 1
	@test num_classes_reflections(ImprimitiveComplexReflectionGroup(3,1,4)) == 3
	@test num_classes_reflections(ImprimitiveComplexReflectionGroup(3,3,4)) == 1
	@test num_classes_reflections(ImprimitiveComplexReflectionGroup(4,1,4)) == 4
	@test num_classes_reflections(ImprimitiveComplexReflectionGroup(4,2,4)) == 2
	@test num_classes_reflections(ImprimitiveComplexReflectionGroup(4,4,4)) == 1
	@test num_classes_reflections(ImprimitiveComplexReflectionGroup(5,1,4)) == 5
	@test num_classes_reflections(ImprimitiveComplexReflectionGroup(5,5,4)) == 1
	@test num_classes_reflections(ImprimitiveComplexReflectionGroup(2,1,5)) == 2
	@test num_classes_reflections(ImprimitiveComplexReflectionGroup(2,2,5)) == 1
	@test num_classes_reflections(ImprimitiveComplexReflectionGroup(3,1,5)) == 3
	@test num_classes_reflections(ImprimitiveComplexReflectionGroup(3,3,5)) == 1
	@test num_classes_reflections(ImprimitiveComplexReflectionGroup(4,1,5)) == 4
	@test num_classes_reflections(ImprimitiveComplexReflectionGroup(4,2,5)) == 2
	@test num_classes_reflections(ImprimitiveComplexReflectionGroup(4,4,5)) == 1
	@test num_classes_reflections(ImprimitiveComplexReflectionGroup(5,1,5)) == 5
	@test num_classes_reflections(ImprimitiveComplexReflectionGroup(5,5,5)) == 1

	#num_hyperlanes
	@test num_hyperplanes(ImprimitiveComplexReflectionGroup(2,1,2)) == 4
	@test num_hyperplanes(ImprimitiveComplexReflectionGroup(3,1,2)) == 5
	@test num_hyperplanes(ImprimitiveComplexReflectionGroup(3,3,2)) == 3
	@test num_hyperplanes(ImprimitiveComplexReflectionGroup(4,1,2)) == 6
	@test num_hyperplanes(ImprimitiveComplexReflectionGroup(4,2,2)) == 6
	@test num_hyperplanes(ImprimitiveComplexReflectionGroup(4,4,2)) == 4
	@test num_hyperplanes(ImprimitiveComplexReflectionGroup(5,1,2)) == 7
	@test num_hyperplanes(ImprimitiveComplexReflectionGroup(5,5,2)) == 5
	@test num_hyperplanes(ImprimitiveComplexReflectionGroup(2,1,3)) == 9
	@test num_hyperplanes(ImprimitiveComplexReflectionGroup(2,2,3)) == 6
	@test num_hyperplanes(ImprimitiveComplexReflectionGroup(3,1,3)) == 12
	@test num_hyperplanes(ImprimitiveComplexReflectionGroup(3,3,3)) == 9
	@test num_hyperplanes(ImprimitiveComplexReflectionGroup(4,1,3)) == 15
	@test num_hyperplanes(ImprimitiveComplexReflectionGroup(4,2,3)) == 15
	@test num_hyperplanes(ImprimitiveComplexReflectionGroup(4,4,3)) == 12
	@test num_hyperplanes(ImprimitiveComplexReflectionGroup(5,1,3)) == 18
	@test num_hyperplanes(ImprimitiveComplexReflectionGroup(5,5,3)) == 15
	@test num_hyperplanes(ImprimitiveComplexReflectionGroup(2,1,4)) == 16
	@test num_hyperplanes(ImprimitiveComplexReflectionGroup(2,2,4)) == 12
	@test num_hyperplanes(ImprimitiveComplexReflectionGroup(3,1,4)) == 22
	@test num_hyperplanes(ImprimitiveComplexReflectionGroup(3,3,4)) == 18
	@test num_hyperplanes(ImprimitiveComplexReflectionGroup(4,1,4)) == 28
	@test num_hyperplanes(ImprimitiveComplexReflectionGroup(4,2,4)) == 28
	@test num_hyperplanes(ImprimitiveComplexReflectionGroup(4,4,4)) == 24
	@test num_hyperplanes(ImprimitiveComplexReflectionGroup(5,1,4)) == 34
	@test num_hyperplanes(ImprimitiveComplexReflectionGroup(5,5,4)) == 30
	@test num_hyperplanes(ImprimitiveComplexReflectionGroup(2,1,5)) == 25
	@test num_hyperplanes(ImprimitiveComplexReflectionGroup(2,2,5)) == 20
	@test num_hyperplanes(ImprimitiveComplexReflectionGroup(3,1,5)) == 35
	@test num_hyperplanes(ImprimitiveComplexReflectionGroup(3,3,5)) == 30
	@test num_hyperplanes(ImprimitiveComplexReflectionGroup(4,1,5)) == 45
	@test num_hyperplanes(ImprimitiveComplexReflectionGroup(4,2,5)) == 45
	@test num_hyperplanes(ImprimitiveComplexReflectionGroup(4,4,5)) == 40
	@test num_hyperplanes(ImprimitiveComplexReflectionGroup(5,1,5)) == 55
	@test num_hyperplanes(ImprimitiveComplexReflectionGroup(5,5,5)) == 50

	#num_conjugacy_classes
	@test num_conjugacy_classes(ImprimitiveComplexReflectionGroup(2,1,2)) == 5
	@test num_conjugacy_classes(ImprimitiveComplexReflectionGroup(3,1,2)) == 9
	@test num_conjugacy_classes(ImprimitiveComplexReflectionGroup(4,1,2)) == 14
	@test num_conjugacy_classes(ImprimitiveComplexReflectionGroup(5,1,2)) == 20
	@test num_conjugacy_classes(ImprimitiveComplexReflectionGroup(4,2,2)) == 10
	@test num_conjugacy_classes(ImprimitiveComplexReflectionGroup(3,3,2)) == 3
	@test num_conjugacy_classes(ImprimitiveComplexReflectionGroup(4,4,2)) == 5
	@test num_conjugacy_classes(ImprimitiveComplexReflectionGroup(5,5,2)) == 4
	@test num_conjugacy_classes(ImprimitiveComplexReflectionGroup(2,1,3)) == 10
	@test num_conjugacy_classes(ImprimitiveComplexReflectionGroup(3,1,3)) == 22
	@test num_conjugacy_classes(ImprimitiveComplexReflectionGroup(4,1,3)) == 40
	@test num_conjugacy_classes(ImprimitiveComplexReflectionGroup(5,1,3)) == 65
	@test num_conjugacy_classes(ImprimitiveComplexReflectionGroup(2,2,3)) == 5
	@test num_conjugacy_classes(ImprimitiveComplexReflectionGroup(4,2,3)) == 20
	@test num_conjugacy_classes(ImprimitiveComplexReflectionGroup(3,3,3)) == 10
	@test num_conjugacy_classes(ImprimitiveComplexReflectionGroup(4,4,3)) == 10
	@test num_conjugacy_classes(ImprimitiveComplexReflectionGroup(5,5,3)) == 13
	@test num_conjugacy_classes(ImprimitiveComplexReflectionGroup(2,1,4)) == 20
	@test num_conjugacy_classes(ImprimitiveComplexReflectionGroup(3,1,4)) == 51
	@test num_conjugacy_classes(ImprimitiveComplexReflectionGroup(4,1,4)) == 105
	@test num_conjugacy_classes(ImprimitiveComplexReflectionGroup(5,1,4)) == 190
	@test num_conjugacy_classes(ImprimitiveComplexReflectionGroup(2,2,4)) == 13
	@test num_conjugacy_classes(ImprimitiveComplexReflectionGroup(4,2,4)) == 60
	@test num_conjugacy_classes(ImprimitiveComplexReflectionGroup(3,3,4)) == 17
	@test num_conjugacy_classes(ImprimitiveComplexReflectionGroup(4,4,4)) == 33
	@test num_conjugacy_classes(ImprimitiveComplexReflectionGroup(5,5,4)) == 38
	@test num_conjugacy_classes(ImprimitiveComplexReflectionGroup(2,1,5)) == 36
	@test num_conjugacy_classes(ImprimitiveComplexReflectionGroup(3,1,5)) == 108
	@test num_conjugacy_classes(ImprimitiveComplexReflectionGroup(4,1,5)) == 252
	@test num_conjugacy_classes(ImprimitiveComplexReflectionGroup(5,1,5)) == 506
	@test num_conjugacy_classes(ImprimitiveComplexReflectionGroup(2,2,5)) == 18
	@test num_conjugacy_classes(ImprimitiveComplexReflectionGroup(4,2,5)) == 126
	@test num_conjugacy_classes(ImprimitiveComplexReflectionGroup(3,3,5)) == 36
	@test num_conjugacy_classes(ImprimitiveComplexReflectionGroup(4,4,5)) == 63
	@test num_conjugacy_classes(ImprimitiveComplexReflectionGroup(5,5,5)) == 106

end
