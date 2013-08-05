using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using NUnit.Framework;

namespace FizzBuzzTDDExample
{
    /// <summary>
    /// Write a program that prints the numbers from 1 to 100.
    /// But for multiples of three print “Fizz” instead of the number.
    /// And for the multiples of five print “Buzz” instead of the number.
    /// And for numbers which are multiples of both three and five print “FizzBuzz” instead of the number.
    /// </summary>
  
    [TestFixture]
    public class FizzBuzzTests
    {
        [Test]
        public void IsThreeMultipleOfThreeTest()
        {
            FizzBuzz fb = new FizzBuzz();

            bool isMultiple = fb.IsMultipleOfThree(3);
            Assert.That(isMultiple, Is.True);
        }

        [Test]
        public void IsFiveMultipleOfFiveTest()
        {
            FizzBuzz fb = new FizzBuzz();

            bool isMultiple = fb.IsMultipleOfFive(5);
            Assert.That(isMultiple, Is.True);
        }

        [Test]
        public void TextOfMultipleOfThreeIsFizzTest()
        {
            FizzBuzz fb = new FizzBuzz();

            string text = fb.GetTextOfNumber(3);
            Assert.That(text, Is.EqualTo("Fizz"));
        }

        [Test]
        public void TextOfMultipleOfFiveIsBuzzTest()
        {
            FizzBuzz fb = new FizzBuzz();

            string text = fb.GetTextOfNumber(5);
            Assert.That(text, Is.EqualTo("Buzz"));
        }

        [Test]
        public void TextOfMultipleOfThreeAndFiveIsFizzBuzzTest()
        {
            FizzBuzz fb = new FizzBuzz();

            string text = fb.GetTextOfNumber(15);
            Assert.That(text, Is.EqualTo("FizzBuzz"));
        }

        [Test]
        public void TextOfNonMultipleOfThreeOrFiveIsTheNumberTest()
        {
            FizzBuzz fb = new FizzBuzz();

            string text = fb.GetTextOfNumber(4);
            Assert.That(text, Is.EqualTo("4"));
        }

        [Test]
        public void RunItToFifteenTest()
        {
            FizzBuzz fb = new FizzBuzz();

            string text = fb.RunItAll(15);
            Assert.That(text, Is.EqualTo("1 2 Fizz 4 Buzz Fizz 7 8 Fizz Buzz 11 Fizz 13 14 FizzBuzz "));
        }
    }
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            