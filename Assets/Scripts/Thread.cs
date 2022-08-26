using System.Collections;
using System.Collections.Generic;
using System;
using System.Threading;
using System.Threading.Tasks;

public class Thread
{
    private bool _cancel = false;

    private void GetPerson(object o)
    {
        // Threadクラスで同期的処理を行う。
        var result = new List<Person>();
        for (int i = 0; i < 5; i++)
        {
            System.Threading.Thread.Sleep(10);
            result.Add(new Person(i, "Name"));
        }
        //ここのスレッドはワーカースレッド（サブスレッドになっている）
        // ここでUnity上の何かを変える場合は
        try
        {

        } catch
        {

        } finally
        {

        }
        CancellationToken _token = new System.Threading.CancellationToken();
        //このメソッドを発火させるとキャンセルメソッドの発火。
        _token.ThrowIfCancellationRequested();
        
    }


    private void GetPersonNotDoki()
    {
        var result = new List<Person>();
        // Threading.Theadに非同期で実行したい処理を入れて
        var thread = new System.Threading.Thread(GetPerson);
        // 実際にスレッドをスタートさせる。
        thread.Start();

        System.Threading.ThreadPool.QueueUserWorkItem(GetPerson,new Person(1, ""));
        

    }

    private void A()
    {

    }

    private async void GetTaskPerson()
    {
        // Aのメソッドにはなんの型を引数に入れてもOKvar

        var context = TaskScheduler.FromCurrentSynchronizationContext();

        //Task.Run(() => A()).ContinueWith(element => {

        //}, context);

        string keyword = await Task.Run(() => B());
        
    }

    private string B()
    {
        return "";
    }
}

public sealed class Person
{
    public int age;
    public string name;

    public Person(int age, string name)
    {
        this.age = age;
        this.name = name;
    }
} 
