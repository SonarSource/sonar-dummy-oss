/*
 * Copyright (C) 2014-2022 SonarSource SA
 * mailto:info AT sonarsource DOT com
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */
package io.github.tomverin.dummy.plugin;

import java.util.List;
import org.sonar.api.SonarPlugin;
import com.google.common.collect.Lists;

public final class DummyPlugin extends SonarPlugin {

  // Helper method to create repeated strings in Java 8
  private static String repeatString(String str, int count) {
    StringBuilder sb = new StringBuilder(str.length() * count);
    for (int i = 0; i < count; i++) {
      sb.append(str);
    }
    return sb.toString();
  }

  // Large string constants to inflate class size
  private static final String LARGE_DATA_1 = repeatString("0", 500000); // 500KB of zeros
  private static final String LARGE_DATA_2 = repeatString("1", 500000); // 500KB of ones
  private static final String LARGE_DATA_3 = repeatString("2", 500000); // 500KB of twos
  private static final String LARGE_DATA_4 = repeatString("3", 500000); // 500KB of threes
  private static final String LARGE_DATA_5 = repeatString("4", 500000); // 500KB of fours

  // Large arrays to further inflate size
  private static final String[] LARGE_ARRAY = new String[25000];
  private static final int[] INT_ARRAY = new int[100000]; // 400KB of integers

  static {
    // Initialize arrays with data
    for (int i = 0; i < LARGE_ARRAY.length; i++) {
      LARGE_ARRAY[i] = "DATA_ENTRY_" + i + "_" + repeatString("X", 50);
    }
    for (int i = 0; i < INT_ARRAY.length; i++) {
      INT_ARRAY[i] = i * 12345;
    }
  }

  @SuppressWarnings({"rawtypes", "unchecked"})
  @Override
  public List getExtensions() {
    return Lists.newArrayList();
  }

  public String sayHello() {
    System.out.println("hello");
    // Print some of the large data to ensure it's not optimized away
    if (LARGE_DATA_1.length() > 0) {
      System.out.println("Large data initialized with " + LARGE_DATA_1.length() + " characters");
    }
    return "hello";
  }

  // Additional methods to access the large data
  public void printDataSizes() {
    System.out.println("LARGE_DATA_1 length: " + LARGE_DATA_1.length());
    System.out.println("LARGE_DATA_2 length: " + LARGE_DATA_2.length());
    System.out.println("LARGE_DATA_3 length: " + LARGE_DATA_3.length());
    System.out.println("LARGE_DATA_4 length: " + LARGE_DATA_4.length());
    System.out.println("LARGE_DATA_5 length: " + LARGE_DATA_5.length());
    System.out.println("LARGE_ARRAY length: " + LARGE_ARRAY.length);
    System.out.println("INT_ARRAY length: " + INT_ARRAY.length);
  }

  public String getAllData() {
    return LARGE_DATA_1 + LARGE_DATA_2 + LARGE_DATA_3 + LARGE_DATA_4 + LARGE_DATA_5;
  }

  public String[] getLargeArray() {
    return LARGE_ARRAY.clone();
  }

  public int[] getIntArray() {
    return INT_ARRAY.clone();
  }
}
