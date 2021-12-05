package day18

import scala.annotation.tailrec
import scala.util.parsing.combinator.RegexParsers

object Main extends App {

  sealed trait UnstableNode

  case class Exploded(node: Node, addLeft: Int, addRight: Int)
    extends UnstableNode

  sealed trait Node extends UnstableNode {
    def addToLeftMost(x: Int): Node

    def addToRightMost(x: Int): Node

    def magnitude(): Int

    def explodeAux(depth: Int = 0): UnstableNode = {
      this match {
        case Pair(Value(a), Value(b)) => {
          if (depth >= 4)
            Exploded(Value(0), a, b)
          else
            this
        }
        case Pair(a, b) => {
          a.explodeAux(depth + 1) match {
            case Exploded(node, left, right) => Exploded(Pair(node, b
              .addToLeftMost(right)),
              left, 0)
            case _ =>
              b.explodeAux(depth + 1) match {
                case Exploded(node, left, right) => Exploded(Pair(a
                  .addToRightMost(left), node),
                  0, right)
                case _ => this
              }
          }
        }
        case Value(_) => this
      }
    }

    def explode(): Option[Node] = {
      explodeAux() match {
        case Exploded(node, _, _) => Some(node)
        case _ => None
      }
    }

    def split(): Option[Node] = {
      this match {
        case Value(x) => {
          if (x >= 10) Some(Pair(Value(x / 2), Value((x + 1) / 2)))
          else None
        }
        case Pair(a, b) => {
          a.split() match {
            case Some(newA) => Some(Pair(newA, b))
            case None => {
              b.split() match {
                case Some(newB) => Some(Pair(a, newB))
                case None => None
              }
            }
          }
        }
      }
    }

    @tailrec
    final def reduce(): Node = {
      explode() match {
        case Some(node) => node.reduce()
        case None => split() match {
          case Some(node) => node.reduce()
          case None => this
        }
      }
    }

    def +(other: Node): Node = {
      Pair(this, other).reduce()
    }

  }

  case class Value(value: Int) extends Node {
    def addToLeftMost(x: Int): Node = {
      if (x == 0) this
      else Value(value + x)
    }

    def addToRightMost(x: Int): Node = {
      if (x == 0) this
      else Value(value + x)
    }

    override def magnitude(): Int = value
  }

  case class Pair(left: Node, right: Node) extends Node {
    def addToLeftMost(x: Int): Node = {
      if (x == 0) this else Pair(left.addToLeftMost(x), right)
    }

    def addToRightMost(x: Int): Node = {
      if (x == 0) this else Pair(left, right.addToRightMost(x))
    }

    override def magnitude(): Int = 3 * left.magnitude() + 2 * right.magnitude()
  }

  object SnailFishParser extends RegexParsers {
    def number: Parser[Node] = """\d""".r ^^ { digit => Value(digit.toInt) }

    def pair: Parser[Node] = {
      "[" ~ node ~ "," ~ node ~ "]" ^^ {
        case _ ~ a ~ _ ~ b ~ _ => Pair(a, b)
      }
    }

    def node: Parser[Node] = number | pair

    def apply(input: String): Node = {
      parseAll(pair, input) match {
        case Success(node, _) => node
        case _ => scala.sys.error("bad input")
      }
    }
  }

  val lines = scala.io.Source.fromFile(args(0)).getLines().toArray;
  val fishes = lines.map(line => SnailFishParser(line))
  val totalMag = fishes.reduce(_ + _).magnitude()
  println(s"part 1: ${totalMag}")
  val mags = for (fish1 <- fishes; fish2 <- fishes if fish1.ne(fish2)) yield
    (fish1 + fish2).magnitude()
  val maxMag = mags.foldLeft(0)(_.max(_))
  println(s"part 2: ${maxMag}")
}