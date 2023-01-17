using UnityEngine;

namespace DefaultNamespace
{
    public class EulerAnglesTest : MonoBehaviour
    {
        public float heading;
        public float pitch;
        public float bank;

        EulerAnglesTest(float heading, float pitch, float bank)
        {
            this.heading = heading;
            this.pitch = pitch;
            this.bank = bank;
        }
    }
}