private func merge(_ sort:(a:[Any], b:[Any]), by:(a:[Double], b:[Double])) -> (mergedArrays:[Any], by:[Double]) {
    var Sort = sort
    var By = by

    var mergedAny : [Any] = []
    var mergedDouble : [Double] = []

    while By.a.count != 0 && By.b.count != 0 {
        if By.a[0] > By.b[0] {
            mergedAny.append(Sort.a[0])
            mergedDouble.append(By.a[0])

            Sort.a.remove(at:0)
            By.a.remove(at:0)
        } else {
            mergedAny.append(Sort.b[0])
            mergedDouble.append(By.b[0])

            Sort.b.remove(at:0)
            By.b.remove(at:0)
        }
    }

    while By.a.count != 0 {
        mergedAny.append(Sort.a[0])
        mergedDouble.append(By.a[0])
        
        Sort.a.remove(at:0)
        By.a.remove(at:0)
    }
    while By.b.count != 0 {
        mergedAny.append(Sort.b[0])
        mergedDouble.append(By.b[0])

        Sort.b.remove(at:0)
        By.b.remove(at:0)
    }

    return (mergedArrays:mergedAny, by:mergedDouble)
}

private func Sort(_ sort:[Any], by:[Double]) -> (sorted:[Any], by:[Double]) {
    var sortingArray = sort
    var workingArray = by

    if workingArray.count > 1 {
        let midpoint = Int(Double(workingArray.count)/2.0 + 0.5)

        let part1Any = Array(sortingArray[..<midpoint])
        let part2Any = Array(sortingArray[midpoint...])
        let part1Double = Array(workingArray[..<midpoint])
        let part2Double = Array(workingArray[midpoint...])

        let part1 = Sort(part1Any, by:part1Double)
        let part2 = Sort(part2Any, by:part2Double)

        let arrays = merge((a:part1.sorted, b:part2.sorted),by:(a:part1.by, b:part2.by))

        sortingArray = arrays.mergedArrays
        workingArray = arrays.by
    }

    return (sorted:sortingArray, by:workingArray)
}

public func mergeSort(_ sort:[Any], by:[Double]) -> [Any] {
    let sorted = Sort(sort, by:by).sorted
    print("Sorted \(sorted.count) items")
    return sorted
}
