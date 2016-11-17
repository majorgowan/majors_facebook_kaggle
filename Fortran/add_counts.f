      program add_counts

          implicit none

          integer iline

c         variables for reading counts file 
          integer nplaces
          parameter ( nplaces = 108390 )
          integer place_count(nplaces)
          character(len=10) place_list(nplaces)

c         variables for stepping through samples file
          integer row_id
          integer nneighbours
          parameter ( nneighbours = 10 )
          character(len=10) places(nneighbours)

c         variables for stepping through neighbours list
          integer ineighbour, index, neighbourhood_counts(nneighbours)
          integer total
          real neighbourhood_fraction(nneighbours)

c         processing test file flag
          integer testing

c         ----------------------------------

          testing = 1

c         read coordinates of place_id counts
c         open places file
          open(unit = 70,
     &      file = '../Data/place_id_counts.csv',
     &      action = 'read')
c         throw away headers line
          read(70,*)
          do iline = 1, nplaces
c           only need first two items on each line (place_id and count)
            read(70,*) place_list(iline), 
     &                 place_count(iline)
          enddo

          if (testing.eq.1) then

c             open neighbourhood file for reading
              open(unit = 71, 
     &          file = './CSV/test_neighbourhood.csv',
     &          action = 'read')

c             open counts file for writing
              open(unit = 80, 
     &          file = 'test_counts.csv', 
     &          action = 'write')

          else

c             open neighbourhood file for reading
              open(unit = 71, 
     &          file = './CSV/train_neighbourhood.csv',
     &          action = 'read')

c             open counts file for writing
              open(unit = 80, 
     &          file = 'train_counts.csv', 
     &          action = 'write')

          end if

c         write headers to csv files
          write(80, *) 'row_id,counts'

c         step through neighbourhood file and process each line
c         throw away headers line
          read(71,*)
          do iline = 1,29118023
c          do iline = 1,1000000

c            if (modulo(iline,20000).eq.0) then
c                print *, iline, ' . . .'
c            end if

            read(71, *, end=100) row_id, places

            do ineighbour = 1, nneighbours
              call lookup(place_list, nplaces, 
     &                    places(ineighbour), index)
              neighbourhood_counts(ineighbour) = place_count(index)
            enddo

            total = 0
            do ineighbour = 1, nneighbours
              total = total + neighbourhood_counts(ineighbour)
            enddo

            do ineighbour = 1, nneighbours
              neighbourhood_fraction(ineighbour) = 
     &                real(neighbourhood_counts(ineighbour)) / total
            enddo              

            write(80, fmt="(1(g0:','),*(f6.4:' '))") row_id,
     &                                  neighbourhood_fraction
          enddo
 100      continue  

c          call lookup(place_list, 10, 'Good bye  ', index)
c          print *, index

          close(70)
          close(71)
          close(80)
      end program add_counts


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


