using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FizzBuzzTDDExample
{
    public class FizzBuzz
    {
        public bool IsMultipleOfThree(int number)
        {
            return (number % 3) == 0;
        }

        public bool IsMultipleOfFive(int number)
        {
            return (number % 5) == 0;
        }

        public string GetTextOfNumber(int number)
        {
            if (IsMultipleOfThree(number) && IsMultipleOfFive(number))
                return "FizzBuzz";
            if (IsMultipleOfFive(number))
                return "Buzz";
            if (IsMultipleOfThree(number))
                return "Fizz";
            else
                return number.ToString();
        }

        public string RunItAll(int number)
        {
            StringBuilder sb = new StringBuilder();

            for (int i = 1; i <= number; ++i)
            {
                sb.AppendFormat("{0} ", GetTextOfNumber(i));
            }

            return sb.ToString();
        }
    }
}
