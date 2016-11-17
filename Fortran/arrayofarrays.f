      program arrayofarrays

          implicit none

          integer myarray
          dimension myarray(3,10)

          integer irow, jcol

          do irow = 1, 10
            do jcol = 1, 3

              myarray(jcol, irow) = irow

            end do
          end do

          print *, myarray
          print *, ' '

          print *, myarray(1,:)

          print *, ' '

          print *, myarray(:,1)

      end program arrayofarrays

              
