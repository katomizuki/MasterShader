using UnityEngine;

public class Rotater : MonoBehaviour
{

    [SerializeField] private float _speed = 1f;

    private bool _running = true;
    
    // Update is called once per frame
    void Update()
    {
        if (!_running) return;
        transform.Rotate(new Vector3(0, _speed, 0));
    }

    private void StartRotate()
    {
        _running = true;
    }

    private void StopRotate()
    {
        _running = false;
    }

#if UNITY_EDITOR
    [UnityEditor.CustomEditor(typeof(Rotater))]
    private class RotateEditor : UnityEditor.Editor
    {
        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();
            Rotater rotater = target as Rotater;
            // Buttonがレイアウトされる。
            if (GUILayout.Button("start"))
            {
                rotater.StartRotate();
            }

            if (GUILayout.Button("stop"))
            {
                rotater.StopRotate();
            }
        }
    }
#endif
}
