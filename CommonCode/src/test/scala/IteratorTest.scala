/**
 * Created by shy on 2023/4/10 星期一 18:49
 */
object IteratorTest extends App {
  val lst = 1 to 100
  private val iterator: Iterator[Int] = lst.iterator

  private val sb = new StringBuilder()

  var acc = 0
  while (iterator.hasNext) {
    //    iterator.addString(sb, ",")
    sb.append(iterator.next())
    acc += 1
    if (acc % 10 == 0) {
      println(sb.mkString("", ",", ""))
      println(acc)
      sb.clear()
    }
  }

}
