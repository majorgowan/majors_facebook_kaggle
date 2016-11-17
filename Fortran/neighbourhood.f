      program neighbourhood

          implicit none

          integer iline, index

c         variables for reading medians file 
          integer nplaces
          parameter ( nplaces = 108390 )
          double precision place_x_list(nplaces), place_y_list(nplaces)
          character(len=10) place_list(nplaces)

c         variables for stepping through samples file
          integer num, row_id
          double precision place_x, place_y
          double precision accuracy
          integer time
          character(len=10) place

c         variables for collecting distances
          integer nneighbours
          parameter ( nneighbours = 10 )
          character(len=10) neighbours(nneighbours)
          double precision dists(nneighbours)

c         processing test file flag
          integer testing

c         ----------------------------------

          testing = 1

c         read coordinates of place_id centres
c         open places file
          open(unit = 70,
     &      file = '../Data/place_id_medians.csv',
     &      action = 'read')
c         throw away headers line
          read(70,*)
          do iline = 1, nplaces
            read(70,*) place_list(iline), 
     &                 place_x_list(iline), place_y_list(iline)
          enddo

          if (testing.eq.1) then

c             open samples file for reading
              open(unit = 71, 
     &          file = '../Data/test.csv',
     &          action = 'read')

c             open neighbourhoods and distances files for writing
              open(unit = 80, 
     &          file = 'test_neighbourhood.csv', 
     &          action = 'write')
              open(unit = 81, 
     &          file = 'test_distances.csv', 
     &          action = 'write')

          else

c             open samples file for reading
              open(unit = 71, 
     &          file = '../Data/train.csv',
     &          action = 'read')

c             open neighbourhoods and distances files for writing
              open(unit = 80, 
     &          file = 'train_neighbourhood.csv', 
     &          action = 'write')
              open(unit = 81, 
     &          file = 'train_distances.csv', 
     &          action = 'write')

          end if

c         write headers to csv files
          write(80, *) 'row_id,place_id'
          write(81, *) 'row_id,distances'

c         step through samples file and process each line
c         throw away headers line
          read(71,*)
          do iline = 1,29118023

c            if (modulo(iline,20000).eq.0) then
c                print *, iline, ' . . .'
c            end if

c           testing file has no "place_id" column!
            if (testing.eq.1) then
                read(71, *, end=100) row_id, place_x, place_y, 
     &                               accuracy, time
            else
                read(71, *, end=100) row_id, place_x, place_y, 
     &                               accuracy, time, place
            endif

            call nearest(place_list, place_x_list, place_y_list,
     &                   nplaces, place_x, place_y,
     &                   nneighbours, neighbours, dists)

            write(80, fmt="(1(g0:','),*(g0:' '))") row_id,neighbours
            write(81, fmt="(1(g0:','),*(f12.10:' '))") row_id,dists
          enddo
 100      continue  

c          call lookup(place_list, 10, 'Good bye  ', index)
c          print *, index

          close(70)
          close(71)
          close(80)
          close(81)
      end program neighbourhood


      subroutine dist(x1, y1, x2, y2, d)
          implicit none
          double precision x1, y1, x2, y2, d

          d = (x2-x1)**2 + (y2-y1)**2

          return

      end subroutine dist


      subroutine nearest(place_list, place_x_list, place_y_list,
     &                   list_length, place_x, place_y,
     &                   nn, neighbours, dists)

          implicit none

          integer list_length, nplaces
          double precision place_x, place_y
          double precision place_x_list(list_length), 
     &                     place_y_list(list_length)
          character(len=10) place_list(list_length)

          integer nn
          character(len=10) neighbours(nn)
          double precision d, dists(nn)

          integer irow, ineighbour, jneighbour

          do ineighbour = 1,nn
            dists(ineighbour) = 1.e10
            neighbours(ineighbour) = '0000000000'
          enddo

          do irow = 1,list_length
            call dist(place_x, place_y, 
     &                place_x_list(irow), place_y_list(irow), 
     &                d)

            ineighbour = 0
            do while (ineighbour.lt.nn)
              ineighbour = ineighbour + 1
              if (d.le.dists(ineighbour)) then
                  do jneighbour = nn, ineighbour+1, -1
                    dists(jneighbour) = dists(jneighbour-1)
                    neighbours(jneighbour) = neighbours(jneighbour-1)
                  enddo
                  dists(ineighbour) = d
                  neighbours(ineighbour) = place_list(irow)
                  ineighbour = nn
              end if 
            enddo

          enddo

      end subroutine nearest


      subroutine lookup(place_list, list_length, place, index)
          implicit none

          integer list_length
          character(len=10) place_list(list_length)
          character(len=10) place
          integer index
          
          integer ii

          index = 0
          ii = 1
          do while (index.eq.0)
            if (place_list(ii).eq.place) then
              index = ii                
            endif
            ii = ii + 1
          enddo

          return
      end subroutine lookup


