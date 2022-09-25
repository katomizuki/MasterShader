using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
public class Scan : MonoBehaviour
{
    [SerializeField] private Button button;

    [SerializeField] private Animator _animator;
    // Start is called before the first frame update
    void Start()
    {
        button.onClick.AddListener(ScanEvent);
    }

    private void ScanEvent()
    {
        _animator.SetTrigger("Scan");
    }
    // Update is called once per frame
    void Update()
    {
        
    }
}
