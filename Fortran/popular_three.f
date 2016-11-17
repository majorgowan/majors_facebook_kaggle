      program popular_three

          implicit none

          integer iline

c         variables for stepping through samples file
          integer row_id
          integer nneighbours
          parameter ( nneighbours = 10 )
          character(len=10) places(nneighbours)
          real popularity(nneighbours)

          character(len=10) pop_three(3)

c         processing test file flag
          integer testing

c         ----------------------------------

          testing = 1

          if (testing.eq.1) then
c             open neighbourhood file for reading
              open(unit = 71, 
     &             file = './CSV/test_neighbourhood.csv',
     &             action = 'read')

c             open popularity file for reading
              open(unit = 72, 
     &             file = './CSV/test_counts.csv',
     &             action = 'read')

c             open popular-three file for writing
              open(unit = 80, 
     &             file = 'test_popular_three.csv', 
     &             action = 'write')

          else

c             open neighbourhood file for reading
              open(unit = 71, 
     &             file = './CSV/train_neighbourhood.csv',
     &             action = 'read')

c             open popularity file for reading
              open(unit = 72, 
     &             file = './CSV/train_counts.csv',
     &             action = 'read')

c             open popular-three file for writing
              open(unit = 80, 
     &             file = 'train_popular_three.csv', 
     &             action = 'write')

          end if

          write(80, *) 'row_id,place_id'

c         step through neighbourhood and counts files and process each line
c         throw away headers line
          read(71,*)
          read(72,*)
          do iline = 1,10000000
c          do iline = 1,100

c            if (modulo(iline,20000).eq.0) then
c                print *, iline, ' . . .'
c            end if

            read(71, *, end=100) row_id, places
            read(72, *, end=100) row_id, popularity

            call maximum_n(places, popularity, nneighbours,
     &                     3, pop_three)

            write(80, fmt="(1(g0:','),*(g0:' '))") row_id,pop_three

          enddo
 100      continue  

c          call lookup(place_list, 10, 'Good bye  ', index)
c          print *, index

          close(71)
          close(72)
          close(80)
      end program popular_three


      subroutine maximum_n(place_list, values, list_length, 
     &                     nn, max_list)

          implicit none

          integer list_length
          real values(list_length)
          character(len=10) place_list(list_length)

          integer nn
          real max_values(nn)
          character(len=10) max_list(nn)

          integer ii, jj, kk

          do ii = 1,nn
            max_values(ii) = 0.
            max_list(ii) = '0000000000'
          enddo

          do kk = 1,list_length
            ii = 0
            do while (ii.lt.nn)
              ii = ii + 1
              if (values(kk).gt.max_values(ii)) then
                  do jj = nn, ii+1, -1
                    max_values(jj) = max_values(jj-1)
                    max_list(jj) = max_list(jj-1)
                  enddo
                  max_values(ii) = values(kk)
                  max_list(ii) = place_list(kk)
                  ii = nn
              end if 
            enddo

          enddo

      end subroutine maximum_n
