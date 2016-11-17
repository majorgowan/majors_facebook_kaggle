      program first_three

          implicit none

          integer iline

c         variables for stepping through samples file
          integer row_id
          integer nneighbours
          parameter ( nneighbours = 3 )
          character(len=10) places(nneighbours)

c         processing test file flag
          integer testing

c         ----------------------------------

          testing = 1

c         open neighbourhood file for reading
          open(unit = 71, 
     &         file = './CSV/test_neighbourhood.csv',
     &         action = 'read')

c         open top-three first for writing
          open(unit = 80, 
     &         file = 'test_top_three.csv', 
     &         action = 'write')

          write(80, *) 'row_id,place_id'

c         step through neighbourhood file and process each line
c         throw away headers line
          read(71,*)
          do iline = 1,29118023
c          do iline = 1,100

c            if (modulo(iline,20000).eq.0) then
c                print *, iline, ' . . .'
c            end if

            read(71, *, end=100) row_id, places
            write(80, fmt="(1(g0:','),*(g0:' '))") row_id,places

          enddo
 100      continue  

c          call lookup(place_list, 10, 'Good bye  ', index)
c          print *, index

          close(71)
          close(80)
      end program first_three

