using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Lamda : MonoBehaviour
{
   
    private void test()
    {

    string[] values = new string[] { "a", "bb", "ccc", "dddd", "eeeee" };
    var result = new List<string>();

        foreach(var val in values)
        {
            if(val.Length > 3)
            {
                result.Add(val);
            }
        }
        GetValuesecond(values, C);
    }

    private bool C(string val)
    {
        return val.Length > 0;
    }

    
    delegate bool LenCheck(string value);
  

    private string[] GetValuesecond(string[] values, LenCheck lenCheck)
    {
        var result = new List<string>();
        foreach (var val in values)
        {
            if (lenCheck(val))
            {
                result.Add(val);
            }
        }
        return result.ToArray();
    }

   private void testmethod()
    {
        // そのまま直書き
        var values = new string[] { "", "", "" };
        var result = GetValuesecond(values,value => value.Length == 3);
    }

    // predicateはboolが戻り値と決まっているDelegate
    private string[] get (string value, Predicate<string> predicate)
    {
        var values = new string[] { "", "", "" };
        var result = new List<string>();
        foreach(var val in values)
        {
            if(predicate(val))
            {

            }
        }
        return result.ToArray();
    }

    private string[] testget(string[] values, int len, Func<string,int,bool> lenCheck)
    {
        var result = new List<string>();
        foreach (var val in values)
        {
            if (lenCheck(val,len))
            {

            }
        }
        return result.ToArray();
    }

    private List<string> getsss (Action<int> action)
    {
        var result = new List<string>();
        for (int i = 1; i < 5;i++)
        {
            result.Add(DateTime.Now.ToString("yyyy/MM/dd"));
            System.Threading.Thread.Sleep(100);
            action(i * 20);
        }
        return result;
    }

}
